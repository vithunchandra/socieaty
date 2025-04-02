import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/transaction-message/repository/transaction_message_repository.dart';
import 'package:socieaty/features/transaction-message/viewstate/chat_view_state.dart';
import 'package:socieaty/shared/view_state.dart';

part 'chat_view_model.g.dart';

@riverpod
class ChatViewModel extends _$ChatViewModel {
  late TransactionMessageRepository _foodOrderChatRepository;

  @override
  ChatViewState build() {
    _foodOrderChatRepository = ref.read(transactionMessageRepositoryProvider);
    return ChatViewState(
      createdMessage: IdleState(),
    );
  }

  Future<void> createMessage(String orderId, String message) async {
    state = state.copyWith(createdMessage: LoadingState());
    final result = await _foodOrderChatRepository.createTransactionMessage(orderId, message);
    switch (result) {
      case Success(data: final data):
        state = state.copyWith(createdMessage: SuccessState(data: data.transactionMessage));
      case Error(error: final error):
        state = state.copyWith(createdMessage: ErrorState(message: error.message));
    }
  }
}
