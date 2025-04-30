import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/support-ticket/enum/support_ticket_status_enum.dart';
import 'package:socieaty/features/support-ticket/repository/support_ticket_repository.dart';
import 'package:socieaty/features/support-ticket/viewstate/support_chat_view_state.dart';
import 'package:socieaty/shared/view_state.dart';

part 'support_chat_view_model.g.dart';

@riverpod
class SupportChatViewModel extends _$SupportChatViewModel {
  late SupportTicketRepository _supportTicketRepository;

  @override
  SupportChatViewState build(String ticketId) {
    _supportTicketRepository = ref.watch(supportTicketRepositoryProvider);
    return SupportChatViewState(
      ticketId: ticketId,
      createMessageState: IdleState(),
      updateTicketState: IdleState(),
    );
  }

  Future<void> createMessage(String message) async {
    state = state.copyWith(createMessageState: LoadingState());
    final result =
        await _supportTicketRepository.createSupportTicketMessage(state.ticketId, message);
    switch (result) {
      case Success(data: final data):
        state = state.copyWith(createMessageState: SuccessState(data: data.supportTicketMessage));
      case Error(error: final error):
        state = state.copyWith(createMessageState: ErrorState(message: error.message));
    }
  }

  Future<void> updateTicket(SupportTicketStatus status) async {
    state = state.copyWith(updateTicketState: LoadingState());
    final result = await _supportTicketRepository.updateSupportTicket(state.ticketId, status);
    switch (result) {
      case Success(data: final data):
        state = state.copyWith(updateTicketState: SuccessState(data: data.supportTicket));
      case Error(error: final error):
        state = state.copyWith(updateTicketState: ErrorState(message: error.message));
    }
  }
}
