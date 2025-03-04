import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/transaction/model/food_order_transaction.dart';
import 'package:socieaty/shared/view_state.dart';

part 'transaction_item_view_state.freezed.dart';

@freezed
class TransactionItemViewState with _$TransactionItemViewState {
  const factory TransactionItemViewState({
    required String id,
    required ViewState<FoodOrderTransaction> transaction,
  }) = _TransactionItemViewState;
}
