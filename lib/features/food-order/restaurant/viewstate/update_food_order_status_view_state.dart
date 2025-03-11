import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/food-order/model/food_order_transaction.dart';
import 'package:socieaty/shared/view_state.dart';

part 'update_food_order_status_view_state.freezed.dart';

@freezed
class UpdateFoodOrderStatusViewState with _$UpdateFoodOrderStatusViewState {
  const factory UpdateFoodOrderStatusViewState({
    required String orderId,
    required ViewState<FoodOrderTransaction> updatedOrder,
  }) = _UpdateFoodOrderStatusViewState;
}
