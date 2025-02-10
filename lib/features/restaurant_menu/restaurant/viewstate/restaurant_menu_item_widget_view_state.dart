import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/restaurant_menu/model/restaurant_menu.dart';
import 'package:socieaty/shared/view_state.dart';

part 'restaurant_menu_item_widget_view_state.freezed.dart';

@freezed
class RestaurantMenuItemWidgetViewState with _$RestaurantMenuItemWidgetViewState {
  const factory RestaurantMenuItemWidgetViewState({
    required String menuId,
    required ViewState<RestaurantMenu> updatedMenu,
  }) = _RestaurantMenuItemWidgetViewState;
}
