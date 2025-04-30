import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/support-ticket/repository/request/create_support_ticket_request_form.dart';
import 'package:socieaty/features/support-ticket/repository/support_ticket_repository.dart';
import 'package:socieaty/features/support-ticket/viewstate/create_support_ticket_view_state.dart';
import 'package:socieaty/shared/view_state.dart';

part 'create_support_ticket_view_model.g.dart';

@riverpod
class CreateSupportTicketViewModel extends _$CreateSupportTicketViewModel {
  late SupportTicketRepository _supportTicketRepository;

  @override
  CreateSupportTicketViewState build() {
    _supportTicketRepository = ref.watch(supportTicketRepositoryProvider);
    return CreateSupportTicketViewState(createdSupportTicketState: IdleState());
  }

  Future<void> createSupportTicket(CreateSupportTicketRequestForm data) async {
    state = state.copyWith(createdSupportTicketState: LoadingState());
    final result = await _supportTicketRepository.createSupportTicket(data);
    switch (result) {
      case Success(data: final data):
        state = state.copyWith(createdSupportTicketState: SuccessState(data: data.supportTicket));
      case Error(error: final error):
        state = state.copyWith(createdSupportTicketState: ErrorState(message: error.toString()));
    }
  }
}
