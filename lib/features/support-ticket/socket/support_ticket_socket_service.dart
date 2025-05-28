import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/websocket_client.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/support-ticket/model/support_ticket.dart';
import 'package:socket_io_client/socket_io_client.dart';

part 'support_ticket_socket_service.g.dart';

@riverpod
SupportTicketSocketService supportTicketSocketService(Ref ref) {
  final AuthLocalRepository authLocalRepository = ref.watch(authLocalRepositoryProvider);
  final token = authLocalRepository.getToken();

  final service = SupportTicketSocketService(
    socket: ref
        .watch(websocketClientProvider('${AppConstants.socieatyBackendUrl}support-ticket', token)),
  );

  return service;
}

class SupportTicketSocketService {
  Socket socket;
  bool _isConnected = false;
  Function(SupportTicket)? _onNewSupportTicketCallback;
  Function(SupportTicket)? _onSupportTicketChangesCallback;

  SupportTicketSocketService({
    required this.socket,
  });

  bool get isConnected => _isConnected;

  initConnection({
    required Function(SupportTicket)? onNewSupportTicketCallback,
    required Function(SupportTicket)? onSupportTicketChangesCallback,
  }) {
    if (_isConnected) return;

    socket.connect();
    socket.on('connection', (_) {
      debugPrint('connect ${_.toString()}');
    });

    debugPrint('Trying Connection');
    socket.onConnect((_) {
      debugPrint('User connected to server');
      _isConnected = true;
      _onNewSupportTicketCallback = onNewSupportTicketCallback;
      _onSupportTicketChangesCallback = onSupportTicketChangesCallback;
      _setupNewSupportTicketListener();
    });

    socket.onDisconnect((_) {
      debugPrint('User disconnected from server');
      _isConnected = false;
    });

    socket.onerror((_) {
      debugPrint('Error Is ${_.toString()}');
      _isConnected = false;
    });
  }

  void disconnect() {
    removeListener('new-support-ticket');
    removeListener('support-ticket-changes');
    socket.clearListeners();
    socket.disconnect();
    socket.dispose();
    _isConnected = false;
    _onNewSupportTicketCallback = null;
    _onSupportTicketChangesCallback = null;
  }

  void _setupNewSupportTicketListener() {
    socket.on('new-support-ticket', (data) {
      final SupportTicket supportTicketData = SupportTicket.fromJson(data);

      debugPrint('New Support Ticket: ${supportTicketData.toJson()}');

      if (_onNewSupportTicketCallback != null) {
        _onNewSupportTicketCallback!(supportTicketData);
      }
    });

    socket.on('support-ticket-changes', (data) {
      final SupportTicket supportTicketData = SupportTicket.fromJson(data);

      debugPrint('Support Ticket Changes: ${supportTicketData.toJson()}');

      if (_onSupportTicketChangesCallback != null) {
        _onSupportTicketChangesCallback!(supportTicketData);
      }
    });
  }

  void removeListener(String event) {
    socket.off(event);
    if (event == 'new-support-ticket') {
      _onNewSupportTicketCallback = null;
    }
    if (event == 'support-ticket-changes') {
      _onSupportTicketChangesCallback = null;
    }
  }
}
