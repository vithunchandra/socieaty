import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/websocket_client.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socket_io_client/socket_io_client.dart';

part 'customer_reservation_socket_service.g.dart';

@Riverpod(keepAlive: true)
CustomerReservationSocketService customerReservationSocketService(Ref ref) {
  final AuthLocalRepository authLocalRepository = ref.watch(authLocalRepositoryProvider);
  final token = authLocalRepository.getToken();
  return CustomerReservationSocketService(
    socket:
        ref.watch(websocketClientProvider('${AppConstants.socieatyBackendUrl}reservation', token)),
  );
}

class CustomerReservationSocketService {
  final Socket _socket;
  bool _isConnected = false;

  CustomerReservationSocketService({required Socket socket}) : _socket = socket;

  bool get isConnected => _isConnected;

  initConnection() {
    if (_isConnected) return;

    _socket.connect();

    _socket.on('connection', (_) {
      debugPrint('connect ${_.toString()}');
    });

    _socket.onConnect((_) {
      debugPrint('Connected to server');
      _isConnected = true;
    });

    _socket.onDisconnect((_) {
      debugPrint('Disconnected from server');
      _isConnected = false;
    });

    _socket.onerror((_) {
      debugPrint('Error Is ${_.toString()}');
      _isConnected = false;
    });
  }

  void disconnect() {
    _socket.disconnect();
    _isConnected = false;
  }

  void trackReservation(String reservationId) {
    debugPrint('Tracking Reservation: $reservationId');
    _socket.emit('track-reservation', reservationId);
  }

  void listenReservationUpdate(String reservationId, Function(dynamic) onReservationUpdate) {
    _socket.on('track-reservation', (data) {
      debugPrint('Reservation Tracking: $data');
      onReservationUpdate(data);
    });
  }

  void removeListener(String event) {
    _socket.off(event);
  }
}
