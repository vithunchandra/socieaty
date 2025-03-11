import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/food-order/model/food_order_transaction.dart';
import 'package:socieaty/shared/view_state.dart';

part 'food_order_item_view_state.freezed.dart';

@freezed
class FoodOrderItemViewState with _$FoodOrderItemViewState {
  const factory FoodOrderItemViewState({
    required String id,
    required ViewState<FoodOrderTransaction> transaction,
  }) = _FoodOrderItemViewState;
}
