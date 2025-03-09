import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/websocket_client.dart';
import 'package:socieaty/core/notifications/local_notification_service.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/transaction/model/food_order_transaction_message.dart';
import 'package:socket_io_client/socket_io_client.dart';

@Riverpod(keepAlive: true)
TransactionMessagesSocketService restaurantSocketService(Ref ref) {
  final AuthLocalRepository authLocalRepository = ref.watch(authLocalRepositoryProvider);
  final token = authLocalRepository.getToken();

  final service = TransactionMessagesSocketService(
    socket:
        ref.watch(websocketClientProvider('${AppConstants.socieatyBackendUrl}food-order', token)),
    notificationService: ref.watch(localNotificationServiceProvider),
  );

  // Register for cleanup when the provider is disposed
  ref.onDispose(() {
    service.disconnect();
  });

  return service;
}

class TransactionMessagesSocketService {
  Socket socket;
  bool _isConnected = false;
  final LocalNotificationService notificationService;

  TransactionMessagesSocketService({
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

  void listenNewTransactionMessage(Function(FoodOrderTransactionMessage) onNewTransactionMessage) {
    socket.on('new-transaction-message', (data) {
      final message = FoodOrderTransactionMessage.fromJson(data);
      onNewTransactionMessage(message);
    });
  }

  void disconnect() {
    socket.disconnect();
    _isConnected = false;
  }
}
