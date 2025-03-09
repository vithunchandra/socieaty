import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/transaction/repository/transaction_repository.dart';
import 'package:socieaty/features/transaction/restaurant/viewstate/update_transaction_status_view_state.dart';
import 'package:socieaty/shared/view_state.dart';

part 'update_transaction_status_view_model.g.dart';

@riverpod
class UpdateTransactionStatusViewModel extends _$UpdateTransactionStatusViewModel {
  late TransactionRepository _transactionRepository;

  @override
  UpdateTransactionStatusViewState build(String orderId) {
    _transactionRepository = ref.read(transactionRepositoryProvider);
    return UpdateTransactionStatusViewState(
      orderId: orderId,
      updatedOrder: IdleState(),
    );
  }

  Future<void> updateTransactionStatus(TransactionStatus newStatus) async {
    state = state.copyWith(updatedOrder: LoadingState());

    final result = await _transactionRepository.updateTransactionStatus(orderId, newStatus);

    switch (result) {
      case Success(data: var data):
        state = state.copyWith(updatedOrder: SuccessState(data: data.transaction));
      case Error(error: var error):
        state = state.copyWith(updatedOrder: ErrorState(message: error.message));
    }
  }
}
