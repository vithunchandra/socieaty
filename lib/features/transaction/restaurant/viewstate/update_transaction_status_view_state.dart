import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/transaction/model/food_order_transaction.dart';
import 'package:socieaty/shared/view_state.dart';

part 'update_transaction_status_view_state.freezed.dart';

@freezed
class UpdateTransactionStatusViewState with _$UpdateTransactionStatusViewState {
  const factory UpdateTransactionStatusViewState({
    required String orderId,
    required ViewState<FoodOrderTransaction> updatedOrder,
  }) = _UpdateTransactionStatusViewState;
}

