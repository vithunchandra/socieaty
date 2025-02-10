import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/restaurant_menu/model/restaurant_menu.dart';
import 'package:socieaty/shared/view_state.dart';

part 'restaurant_menu_detail_widget_view_state.freezed.dart';

@freezed
class RestaurantMenuDetailWidgetViewState with _$RestaurantMenuDetailWidgetViewState {
  const factory RestaurantMenuDetailWidgetViewState({
    required String menuId,
    required ViewState<RestaurantMenu> updatedMenu,
    required ViewState<String> deletedMenuMessage,
  }) = _RestaurantMenuDetailWidgetViewState;
}

