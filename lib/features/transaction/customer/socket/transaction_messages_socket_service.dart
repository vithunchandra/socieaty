import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/websocket_client.dart';
import 'package:socieaty/core/notifications/local_notification_service.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/transaction/model/food_order_transaction_message.dart';
import 'package:socket_io_client/socket_io_client.dart';

part 'transaction_messages_socket_service.g.dart';

@Riverpod(keepAlive: true)
TransactionMessagesSocketService transactionMessagesSocketService(Ref ref) {
  final AuthLocalRepository authLocalRepository = ref.watch(authLocalRepositoryProvider);
  final token = authLocalRepository.getToken();

  final service = TransactionMessagesSocketService(
    socket: ref.watch(
        websocketClientProvider('${AppConstants.socieatyBackendUrl}food-order/message', token)),
    notificationService: ref.watch(localNotificationServiceProvider),
  );

  ref.onDispose(() {
    service.disconnect();
  });

  return service;
}

class TransactionMessagesSocketService {
  Socket socket;
  bool _isConnected = false;
  final LocalNotificationService notificationService;
  Function? onConnected;

  TransactionMessagesSocketService({
    required this.socket,
    required this.notificationService,
  });

  bool get isConnected => _isConnected;

  void initConnection() {
    if (_isConnected) {
      onConnected?.call();
      return;
    }

    notificationService.init();

    socket.connect();
    socket.on('connection', (_) {
      debugPrint('connect ${_.toString()}');
    });

    debugPrint('Trying Connection');
    socket.onConnect((_) {
      debugPrint('connected to server');
      _isConnected = true;
      onConnected?.call();
    });

    socket.onDisconnect((_) {
      debugPrint('disconnected from server');
      _isConnected = false;
    });

    socket.onerror((_) {
      debugPrint('Error Is ${_.toString()}');
      _isConnected = false;
    });

    socket.on('welcome', (data) {
      debugPrint('Welcome: ${data.toString()}');
    });
  }

  void listenNewTransactionMessage(Function(FoodOrderTransactionMessage) onNewTransactionMessage) {
    if (!_isConnected) {
      initConnection();
    }

    socket.on('new-transaction-message', (data) {
      debugPrint('New transaction message: ${data.toString()}');
      final message = FoodOrderTransactionMessage.fromJson(data);
      onNewTransactionMessage(message);
    });
  }

  void removeListener(String eventName) {
    socket.off(eventName == 'transaction-message' ? 'new-transaction-message' : eventName);
  }

  void disconnect() {
    socket.disconnect();
    _isConnected = false;
    onConnected = null;
  }
}
