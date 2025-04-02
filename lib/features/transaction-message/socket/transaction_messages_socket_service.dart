import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/websocket_client.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';

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

  debugPrint('Transaction Messages Socket Service created');

  return service;
}

class TransactionMessagesSocketService {
  final Socket _socket;
  bool _isConnected = false;
  Function(dynamic)? _onNewTransactionMessage;
  bool _isListening = false;

  TransactionMessagesSocketService({
    required Socket socket,
  }) : _socket = socket;

  bool get isConnected => _isConnected;

  initConnection({
    required Function(dynamic) onNewTransactionMessage,
    required Function onConnected,
  }) {
    if (_isConnected) return;

    debugPrint('Connecting to socket');

    _socket.connect();

    _socket.on('connection', (_) {
      debugPrint('connect ${_.toString()}');
    });

    _socket.onConnect((_) {
      if (_isListening || _isConnected) {
        debugPrint('Already listening to New Transaction Message');
        return;
      }

      _isConnected = true;
      _onNewTransactionMessage = onNewTransactionMessage;
      listenNewTransactionMessage("from socket");
      onConnected();
    });

    _socket.onDisconnect((_) {
      debugPrint('disconnected from server');
      _isConnected = false;
      _isListening = false;
    });

    _socket.onerror((_) {
      debugPrint('Error Is ${_.toString()}');
      _isConnected = false;
    });
  }

  void handler(data) {
    debugPrint("Hallo");
    debugPrint('New transaction message: ${DateTime.now()}');
    _socket.listenersAny().forEach((element) {
      debugPrint('Listener: ${element.toString()}');
    });
    _onNewTransactionMessage!(data);
  }

  void listenNewTransactionMessage(String message) {
    debugPrint('Listening New Transaction Message $message');

    _socket.off('new-transaction-message', handler);
    _socket.on('new-transaction-message', handler);
    _isListening = true;
  }

  void removeListener(String eventName) {
    _socket.off(eventName, handler);
    if (eventName == 'new-transaction-message') {
      _onNewTransactionMessage = null;
      _isListening = false;
    }
  }

  void disconnect() {
    removeListener('new-transaction-message');
    _socket.dispose();
    _isConnected = false;
    _isListening = false;
  }
}
