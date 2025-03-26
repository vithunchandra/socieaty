import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/websocket_client.dart';
import 'package:socieaty/core/notifications/local_notification_service.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/reservation/model/reservation.dart';
import 'package:socket_io_client/socket_io_client.dart';

part 'restaurant_reservation_socket_service.g.dart';

@Riverpod(keepAlive: true)
RestaurantReservationSocketService restaurantReservationSocketService(Ref ref) {
  final AuthLocalRepository authLocalRepository = ref.watch(authLocalRepositoryProvider);
  final token = authLocalRepository.getToken();

  final service = RestaurantReservationSocketService(
    socket:
        ref.watch(websocketClientProvider('${AppConstants.socieatyBackendUrl}reservation', token)),
    notificationService: ref.watch(localNotificationServiceProvider),
  );

  ref.onDispose(() {
    service.disconnect();
  });

  return service;
}

class RestaurantReservationSocketService {
  Socket socket;
  bool _isConnected = false;
  final LocalNotificationService notificationService;
  bool _hasNewReservationListener = false;
  Function(Reservation)? _onNewReservationCallback;

  RestaurantReservationSocketService({
    required this.socket,
    required this.notificationService,
  });

  bool get isConnected => _isConnected;

  initConnection() {
    if (_isConnected) return;

    notificationService.init();

    socket.connect();
    socket.on('connection', (_) {
      debugPrint('connect ${_.toString()}');
    });

    debugPrint('Trying Connection');
    socket.onConnect((_) {
      debugPrint('Restaurant connected to server');
      _isConnected = true;

      if (!_hasNewReservationListener) {
        _setupNewReservationListener();
      }
    });

    socket.onDisconnect((_) {
      debugPrint('Restaurant disconnected from server');
      _isConnected = false;
      _hasNewReservationListener = false;
    });

    socket.onerror((_) {
      debugPrint('Error Is ${_.toString()}');
      _isConnected = false;
    });
  }

  void disconnect() {
    removeListener('new-reservation');
    socket.disconnect();
    _isConnected = false;
    _hasNewReservationListener = false;
    _onNewReservationCallback = null;
  }

  void _setupNewReservationListener() {
    if (_hasNewReservationListener) return;

    socket.on('new-reservation', (data) {
      try {
        final Reservation reservationData = Reservation.fromJson(data);
        final formattedTotal =
            (reservationData.grossAmount + reservationData.serviceFee).toIDRFormat();

        final customerName = reservationData.customer.name;
        final reservationTime = reservationData.reservationTime;
        final peopleSize = reservationData.peopleSize;

        final int itemCount = reservationData.menuItems.length;
        final String itemsText = _getItemsDescription(reservationData);

        String notificationTitle =
            'New Reservation #${reservationData.reservationId.substring(0, 8)}';

        String notificationBody = 'Reservation from $customerName\n'
            'Time: ${_formatDateTime(reservationTime)}\n'
            'People: $peopleSize\n'
            'Total: \$$formattedTotal\n'
            'Pre-ordered Items: $itemCount\n'
            '$itemsText';

        notificationService.showNewOrderNotification(
          title: notificationTitle,
          body: notificationBody,
          payload: null,
          orderDetails: reservationData.toJson(),
        );

        if (_onNewReservationCallback != null) {
          debugPrint("Calling onNewReservationCallback");
          _onNewReservationCallback!(reservationData);
        }
      } catch (e) {
        debugPrint('Error processing new reservation: $e');

        notificationService.showNewOrderNotification(
          title: 'New Restaurant Reservation',
          body: 'You have received a new reservation. Tap to view details.',
        );
      }
    });

    _hasNewReservationListener = true;
  }

  void listenNewReservation(Function(Reservation) onNewReservation) {
    _onNewReservationCallback = onNewReservation;

    if (!_isConnected) {
      initConnection();
    } else if (!_hasNewReservationListener) {
      _setupNewReservationListener();
    }
  }

  String _getItemsDescription(Reservation reservation) {
    if (reservation.menuItems.isEmpty) {
      return '';
    }

    final itemsToShow = reservation.menuItems.take(3);

    final StringBuffer buffer = StringBuffer();

    for (final item in itemsToShow) {
      final String itemName = item.menu.name;
      final int quantity = item.quantity;

      buffer.writeln('• $quantity x $itemName');
    }

    if (reservation.menuItems.length > 3) {
      buffer.writeln(
          '• ... and ${reservation.menuItems.length - 3} more item${reservation.menuItems.length - 3 > 1 ? 's' : ''}');
    }

    return buffer.toString();
  }

  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year;

    return '$day/$month/$year $hour:$minute';
  }

  void removeListener(String event) {
    socket.off(event);
    if (event == 'new-reservation') {
      _hasNewReservationListener = false;
      _onNewReservationCallback = null;
    }
  }
}
