import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/websocket_client.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socket_io_client/socket_io_client.dart';

part 'customer_socket_service.g.dart';

@Riverpod(keepAlive: true)
CustomerSocketService customerSocketService(Ref ref) {
  final AuthLocalRepository authLocalRepository = ref.watch(authLocalRepositoryProvider);
  final token = authLocalRepository.getToken();
  return CustomerSocketService(
    socket:
        ref.watch(websocketClientProvider('${AppConstants.socieatyBackendUrl}food-order', token)),
  );
}

class CustomerSocketService {
  final Socket _socket;
  bool _isConnected = false;

  CustomerSocketService({required Socket socket}) : _socket = socket;

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

  void trackOrder(String orderId) {
    debugPrint('Tracking Order: $orderId');
    _socket.emit('track-order', orderId);
  }

  void listenOrderUpdate(String orderId, Function(dynamic) onOrderUpdate) {
    _socket.on('track-order', (data) {
      debugPrint('Order Tracking: $data');
      onOrderUpdate(data);
    });
  }

  // Helper method to remove a specific listener
  void removeListener(String event) {
    _socket.off(event);
  }
}
