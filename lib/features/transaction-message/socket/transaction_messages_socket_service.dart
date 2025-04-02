import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/websocket_client.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/transaction-message/model/transaction_message.dart';

import 'package:socket_io_client/socket_io_client.dart';

part 'transaction_messages_socket_service.g.dart';

@Riverpod(keepAlive: true)
TransactionMessagesSocketService transactionMessagesSocketService(Ref ref) {
  final AuthLocalRepository authLocalRepository = ref.watch(authLocalRepositoryProvider);
  final token = authLocalRepository.getToken();

  final service = TransactionMessagesSocketService(
    socket: ref.watch(
      websocketClientProvider(
        '${AppConstants.socieatyBackendUrl}transaction/message',
        token,
      ),
    ),
  );

  ref.onDispose(() {
    service.disconnect();
  });

  return service;
}

class TransactionMessagesSocketService {
  final Socket _socket;
  bool _isConnected = false;
  bool _isListening = false;
  Function(TransactionMessage)? _onNewTransactionMessage;

  TransactionMessagesSocketService({
    required Socket socket,
  }) : _socket = socket;

  bool get isConnected => _isConnected;

  void initConnection({
    required Function(TransactionMessage) onNewTransactionMessage,
    required Function onConnected,
  }) {
    if (_isConnected) return;

    _socket.connect();
    _socket.on('connection', (_) {
      debugPrint('connect ${_.toString()}');
    });

    debugPrint('Trying Connection');
    _socket.onConnect((_) {
      debugPrint('connected to server');
      _isConnected = true;
      _onNewTransactionMessage = onNewTransactionMessage;
      listenNewTransactionMessage();
      onConnected();
    });

    _socket.onDisconnect((_) {
      debugPrint('disconnected from server');
      _isConnected = false;
    });

    _socket.onerror((_) {
      debugPrint('Error Is ${_.toString()}');
      _isConnected = false;
    });

    _socket.on('welcome', (data) {
      debugPrint('Welcome: ${data.toString()}');
    });
  }

  void listenNewTransactionMessage() {
    if (_isListening) {
      return;
    }
    _isListening = true;
    _socket.on('new-transaction-message', (data) {
      debugPrint('New transaction message: ${DateTime.now()}');
      final message = TransactionMessage.fromJson(data);
      _socket.listenersAny().forEach((element) {
        debugPrint('Listener: ${element.toString()}');
      });
      _onNewTransactionMessage!(message);
    });
  }

  void removeListener(String eventName) {
    _socket.off(eventName);
    if (eventName == 'new-transaction-message') {
      _onNewTransactionMessage = null;
    }
  }

  void disconnect() {
    removeListener('new-transaction-message');
    _socket.disconnect();
    _socket.clearListeners();
    _socket.dispose();
    _isConnected = false;
  }
}
