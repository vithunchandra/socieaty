import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/support-ticket/model/support_ticket_message.dart';
import 'package:socieaty/features/support-ticket/repository/support_ticket_repository.dart';

part 'track_support_ticket_message_provider.g.dart';

@riverpod
Future<List<SupportTicketMessage>> trackSupportTicketMessage(Ref ref, String ticketId) async {
  final repository = ref.watch(supportTicketRepositoryProvider);
  final result = await repository.trackSupportTicketMessage(ticketId);
  switch (result) {
    case Success(data: final data):
      return data.supportTicketMessages;
    case Error(error: final error):
      throw error;
  }
}
