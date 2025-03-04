import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/features/transaction/repository/transaction_repository.dart';
import 'package:socieaty/features/transaction/restaurant/viewstate/transaction_item_view_state.dart';
import 'package:socieaty/shared/view_state.dart';

part 'transaction_item_view_model.g.dart';

@riverpod
class TransactionItemViewModel extends _$TransactionItemViewModel {
  late TransactionRepository transactionRepository;

  @override
  TransactionItemViewState build(String id) {
    return TransactionItemViewState(id: id, transaction: IdleState());
  }
}
