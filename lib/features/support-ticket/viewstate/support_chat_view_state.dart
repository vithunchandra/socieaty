import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/support-ticket/model/support_ticket.dart';
import 'package:socieaty/features/support-ticket/model/support_ticket_message.dart';
import 'package:socieaty/shared/view_state.dart';

part 'support_chat_view_state.freezed.dart';

@freezed
class SupportChatViewState with _$SupportChatViewState {
  const factory SupportChatViewState({
    required String ticketId,
    required ViewState<SupportTicketMessage> createMessageState,
    required ViewState<SupportTicket> updateTicketState,
  }) = _SupportChatViewState;
}
