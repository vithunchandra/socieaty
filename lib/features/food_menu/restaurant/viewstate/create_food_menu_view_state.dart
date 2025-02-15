import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/food_menu/model/food_menu.dart';
import 'package:socieaty/shared/view_state.dart';

part 'create_food_menu_view_state.freezed.dart';

@freezed
class CreateFoodMenuViewState with _$CreateFoodMenuViewState {
  const factory CreateFoodMenuViewState({
    required ViewState<FoodMenu> createMenuState,
  }) = _CreateFoodMenuViewState;
}
