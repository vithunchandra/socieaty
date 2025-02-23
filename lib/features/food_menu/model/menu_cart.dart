import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/food_menu/model/food_menu.dart';

part 'menu_cart.freezed.dart';
part 'menu_cart.g.dart';

@freezed
class MenuCart with _$MenuCart {
  const factory MenuCart({
    required FoodMenu menuItem,
    required int quantity,
  }) = _MenuCart;

  factory MenuCart.fromJson(Map<String, dynamic> json) => _$MenuCartFromJson(json);
}
