import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/websocket_client.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socket_io_client/socket_io_client.dart';

part 'restaurant_socket_service.g.dart';

@Riverpod(keepAlive: true)
RestaurantSocketService restaurantSocketService(Ref ref) {
  final AuthLocalRepository authLocalRepository = ref.watch(authLocalRepositoryProvider);
  final token = authLocalRepository.getToken();
  return RestaurantSocketService(
    socket: ref.watch(websocketClientProvider('${AppConstants.socieatyBackendUrl}food-order', token)),
  );
}

class RestaurantSocketService {
  Socket socket;
  bool _isConnected = false;

  RestaurantSocketService({required this.socket});

  bool get isConnected => _isConnected;

  initConnection() {
    if (_isConnected) return;

    socket.connect();
    socket.on('connection', (_) {
      debugPrint('connect ${_.toString()}');
    });

    debugPrint('Trying Connection');
    socket.onConnect((_) {
      debugPrint('Restaurant connected to server');
      _isConnected = true;
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
    socket.disconnect();
    _isConnected = false;
  }

  void listenNewOrder(Function(dynamic) onNewOrder) {
    socket.on('new-order', (data) {
      debugPrint('New Order Received: $data');
      onNewOrder(data);
    });
  }

  // Remove a specific listener
  void removeListener(String event) {
    socket.off(event);
  }
}
