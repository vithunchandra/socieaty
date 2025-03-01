
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/transaction/model/food_order_transaction.dart';
import 'package:socieaty/shared/view_state.dart';

part 'create_transaction_view_state.freezed.dart';

@freezed
class CreateTransactionViewState with _$CreateTransactionViewState {
  const factory CreateTransactionViewState({
    required ViewState<FoodOrderTransaction> formState,
  }) = _CreateTransactionViewState;

}