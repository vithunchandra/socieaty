

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/support-ticket/model/support_ticket.dart';
import 'package:socieaty/shared/view_state.dart';

part 'create_support_ticket_view_state.freezed.dart';

@freezed
class CreateSupportTicketViewState with _$CreateSupportTicketViewState {
  const factory CreateSupportTicketViewState({
    required ViewState<SupportTicket> createdSupportTicketState,
  }) = _CreateSupportTicketViewState;
}
