import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/food_menu/model/food_menu.dart';
import 'package:socieaty/shared/view_state.dart';

part 'food_menu_detail_widget_view_state.freezed.dart';

@freezed
class FoodMenuDetailWidgetViewState with _$FoodMenuDetailWidgetViewState {
  const factory FoodMenuDetailWidgetViewState({
    required String menuId,
    required ViewState<FoodMenu> updatedMenu,
    required ViewState<String> deletedMenuMessage,
  }) = _FoodMenuDetailWidgetViewState;
}
