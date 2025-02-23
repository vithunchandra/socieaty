import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/food_menu/model/menu_cart.dart';

part 'menu_cart_view_state.freezed.dart';
part 'menu_cart_view_state.g.dart';

@freezed
class MenuCartViewState with _$MenuCartViewState {
  const factory MenuCartViewState({
    required List<MenuCart> menuItems,
    required String restaurantId,
  }) = _MenuCartViewState;

  factory MenuCartViewState.fromJson(Map<String, dynamic> json) =>
      _$MenuCartViewStateFromJson(json);
}
