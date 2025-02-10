import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/restaurant_menu/model/restaurant_menu.dart';
import 'package:socieaty/shared/view_state.dart';

part 'create_restaurant_menu_view_state.freezed.dart';

@freezed
class CreateRestaurantMenuViewState with _$CreateRestaurantMenuViewState {
  const factory CreateRestaurantMenuViewState({
    required ViewState<RestaurantMenu> createMenuState,
  }) = _CreateRestaurantMenuViewState;
}