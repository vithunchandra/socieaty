import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/websocket_client.dart';
import 'package:socieaty/core/notifications/local_notification_service.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/food-order/model/food_order_transaction.dart';
import 'package:socket_io_client/socket_io_client.dart';

part 'restaurant_socket_service.g.dart';

@Riverpod(keepAlive: true)
RestaurantSocketService restaurantSocketService(Ref ref) {
  final AuthLocalRepository authLocalRepository = ref.watch(authLocalRepositoryProvider);
  final token = authLocalRepository.getToken();

  final service = RestaurantSocketService(
    socket:
        ref.watch(websocketClientProvider('${AppConstants.socieatyBackendUrl}food-order', token)),
    notificationService: ref.watch(localNotificationServiceProvider),
  );

  ref.onDispose(() {
    service.disconnect();
  });

  return service;
}

class RestaurantSocketService {
  Socket socket;
  bool _isConnected = false;
  final LocalNotificationService notificationService;

  Function(FoodOrderTransaction)? _onNewOrderCallback;
  Function(String?)? _onNewOrderNotificationTap;
  Function(FoodOrderTransaction)? _onOrderChangesCallback;
  Function(String?)? _onOrderChangesNotificationTap;

  RestaurantSocketService({
    required this.socket,
    required this.notificationService,
  });

  bool get isConnected => _isConnected;

  initConnection({
    required Function(FoodOrderTransaction) onNewOrderCallback,
    required Function(String?) onNewOrderNotificationTap,
    required Function(FoodOrderTransaction) onOrderChangesCallback,
    required Function(String?) onOrderChangesNotificationTap,
  }) {
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
      _onNewOrderCallback = onNewOrderCallback;
      _onNewOrderNotificationTap = onNewOrderNotificationTap;
      _onOrderChangesCallback = onOrderChangesCallback;
      _onOrderChangesNotificationTap = onOrderChangesNotificationTap;
      _setupNewOrderListener();
    });

    socket.onDisconnect((_) {
      debugPrint('Restaurant disconnected from server');
      _isConnected = false;
    });

    socket.onerror((_) {
      debugPrint('Error Is ${_.toString()}');
      _isConnected = false;
    });
  }

  void disconnect() {
    removeListener('new-order');
    removeListener('order-changes');
    socket.disconnect();
    _isConnected = false;
    _onNewOrderCallback = null;
  }

  void _setupNewOrderListener() {
    socket.on('new-order', (data) {
      try {
        final FoodOrderTransaction orderData = FoodOrderTransaction.fromJson(data);
        final formattedTotal = (orderData.grossAmount + orderData.serviceFee).toIDRFormat();

        final customerName = orderData.customer.name;

        final int itemCount = orderData.menuItems.length;
        final String itemsText = _getItemsDescription(orderData);

        String notificationTitle = 'New Order #${orderData.orderId.substring(0, 8)}';

        String notificationBody = 'Order from $customerName\n'
            'Total: \$$formattedTotal\n'
            'Items: $itemCount\n'
            '$itemsText';

        notificationService.setOnNotificationTap(_onNewOrderNotificationTap!);

        notificationService.showNewOrderNotification(
          title: notificationTitle,
          body: notificationBody,
          payload: orderData,
          orderDetails: orderData.toJson(),
        );

        if (_onNewOrderCallback != null) {
          debugPrint("Calling onNewOrderCallback");
          _onNewOrderCallback!(orderData);
        }
      } catch (e) {
        debugPrint('Error processing new order: $e');

        notificationService.showNewOrderNotification(
          title: 'New Restaurant Order',
          body: 'You have received a new order. Tap to view details.',
        );
      }
    });

    socket.on('order-changes', (data) {
      try {
        final FoodOrderTransaction orderData = FoodOrderTransaction.fromJson(data);
        final formattedTotal = (orderData.grossAmount + orderData.serviceFee).toIDRFormat();

        final customerName = orderData.customer.name;

        final int itemCount = orderData.menuItems.length;
        final String itemsText = _getItemsDescription(orderData);

        String notificationTitle = 'Update Order #${orderData.orderId.substring(0, 8)}';

        String notificationBody = 'Order from $customerName\n'
            'Total: \$$formattedTotal\n'
            'Items: $itemCount\n'
            'Status: ${orderData.status}\n'
            '$itemsText';

        notificationService.setOnNotificationTap(_onOrderChangesNotificationTap!);

        notificationService.showNewOrderNotification(
          title: notificationTitle,
          body: notificationBody,
        );

        if (_onOrderChangesCallback != null) {
          _onOrderChangesCallback!(orderData);
        }
      } catch (err) {
        notificationService.showNewOrderNotification(
          title: 'Update Order',
          body: 'Ada update pada pesanan anda. Tap untuk melihat detail.',
        );
        debugPrint('Error processing order changes: $err');
      }
    });
  }

  String _getItemsDescription(FoodOrderTransaction order) {
    if (order.menuItems.isEmpty) {
      return '';
    }

    final itemsToShow = order.menuItems.take(3);

    final StringBuffer buffer = StringBuffer();

    for (final item in itemsToShow) {
      final String itemName = item.menu.name;
      final int quantity = item.quantity;

      buffer.writeln('• $quantity x $itemName');
    }

    if (order.menuItems.length > 3) {
      buffer.writeln(
          '• ... and ${order.menuItems.length - 3} more item${order.menuItems.length - 3 > 1 ? 's' : ''}');
    }

    return buffer.toString();
  }

  void removeListener(String event) {
    socket.off(event);
    if (event == 'new-order') {
      _onNewOrderCallback = null;
    }
    if (event == 'order-changes') {
      _onOrderChangesCallback = null;
    }
  }
}
