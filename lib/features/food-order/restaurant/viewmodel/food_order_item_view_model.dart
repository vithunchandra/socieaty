import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/features/food-order/repository/food_order_repository.dart';
import 'package:socieaty/features/food-order/restaurant/viewstate/food_order_item_view_state.dart';
import 'package:socieaty/shared/view_state.dart';

part 'food_order_item_view_model.g.dart';

@riverpod
class FoodOrderItemViewModel extends _$FoodOrderItemViewModel {
  late FoodOrderRepository foodOrderRepository;

  @override
  FoodOrderItemViewState build(String id) {
    return FoodOrderItemViewState(id: id, transaction: IdleState());
  }
}
