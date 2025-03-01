import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/food_menu/model/food_menu.dart';
import 'package:socieaty/shared/view_state.dart';

part 'food_menu_item_widget_view_state.freezed.dart';

@freezed
class FoodMenuItemWidgetViewState with _$FoodMenuItemWidgetViewState {
  const factory FoodMenuItemWidgetViewState({
    required String menuId,
    required ViewState<FoodMenu> updatedMenu,
  }) = _FoodMenuItemWidgetViewState;
}
