import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/websocket_client.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socket_io_client/socket_io_client.dart';

part 'topup_socket_service.g.dart';

@riverpod
TopupSocketService topupSocketService(Ref ref) {
  final AuthLocalRepository authLocalRepository = ref.watch(authLocalRepositoryProvider);
  final token = authLocalRepository.getToken();

  final service = TopupSocketService(
    socket: ref.watch(websocketClientProvider('${AppConstants.socieatyBackendUrl}topup', token)),
  );

  debugPrint('Topup Socket Service created');

  return service;
}

class TopupSocketService {
  final Socket _socket;
  bool _isConnected = false;
  bool _isListening = false;
  Function(dynamic)? _onTopupNotification;

  TopupSocketService({
    required Socket socket,
  }) : _socket = socket;

  bool get isConnected => _isConnected;

  initConnection({
    required Function(dynamic) onTopupNotification,
    required Function onConnected,
  }) {
    if (_isConnected) return;

    debugPrint('Connecting to socket');

    _socket.connect();

    _socket.on('connection', (_) {
      debugPrint('connect ${_.toString()}');
    });

    _socket.onConnect((_) {
      if (_isConnected || _isListening) return;
      debugPrint('Connected to server');
      _isConnected = true;
      _onTopupNotification = onTopupNotification;
      _listenTopupNotification("from socket");
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
  }

  void _handler(data) {
    debugPrint('topup notification received');
    _onTopupNotification!(data);
  }

  void _listenTopupNotification(String message) {
    _socket.off('topup-notification', _handler);
    _socket.on('topup-notification', _handler);
    _isListening = true;
  }

  void disconnect() {
    _socket.dispose();
    _isConnected = false;
    _isListening = false;
  }
}
