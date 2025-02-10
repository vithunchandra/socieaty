import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/restaurant_menu/model/restaurant_menu.dart';
import 'package:socieaty/shared/view_state.dart';

part 'update_restaurant_menu_view_state.freezed.dart';

@freezed
class UpdateRestaurantMenuViewState with _$UpdateRestaurantMenuViewState {
  const factory UpdateRestaurantMenuViewState({
    required String menuId,
    required ViewState<RestaurantMenu> updateMenuState,
  }) = _UpdateRestaurantMenuViewState;
}
