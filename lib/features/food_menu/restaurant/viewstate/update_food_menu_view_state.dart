import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/food_menu/model/food_menu.dart';
import 'package:socieaty/shared/view_state.dart';

part 'update_food_menu_view_state.freezed.dart';

@freezed
class UpdateFoodMenuViewState with _$UpdateFoodMenuViewState {
  const factory UpdateFoodMenuViewState({
    required String menuId,
    required ViewState<FoodMenu> updateMenuState,
  }) = _UpdateFoodMenuViewState;
}
