import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/food-order/model/food_order_transaction.dart';
import 'package:socieaty/shared/view_state.dart';

part 'create_food_order_view_state.freezed.dart';

@freezed
class CreateFoodOrderViewState with _$CreateFoodOrderViewState {
  const factory CreateFoodOrderViewState({
    required ViewState<FoodOrderTransaction> formState,
  }) = _CreateFoodOrderViewState;
}
