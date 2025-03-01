import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/transaction/customer/viewstate/create_transaction_form_state.dart';
import 'package:socieaty/features/transaction/customer/viewstate/create_transaction_view_state.dart';
import 'package:socieaty/features/transaction/repository/transaction_repository.dart';
import 'package:socieaty/shared/view_state.dart';

part 'create_transaction_view_model.g.dart';

@riverpod
class CreateTransactionViewModel extends _$CreateTransactionViewModel {
  late TransactionRepository _transactionRepository;

  @override
  CreateTransactionViewState build() {
    _transactionRepository = ref.watch(transactionRepositoryProvider);
    return CreateTransactionViewState(formState: IdleState());
  }

  Future<void> createTransaction(CreateTransactionFormState formState) async {
    state = state.copyWith(formState: LoadingState());
    final result = await _transactionRepository.createOrderTransaction(formState);
    switch (result) {
      case Success(data: final data):
        state = state.copyWith(formState: SuccessState(data: data.transaction));
      case Error(error: final error):
        state = state.copyWith(formState: ErrorState(message: error.message));
    }
  }
}
