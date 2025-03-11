import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/food_menu/model/food_menu.dart';

part 'food_order_menu_item.freezed.dart';
part 'food_order_menu_item.g.dart';

@freezed
class FoodOrderMenuItem with _$FoodOrderMenuItem {
  const factory FoodOrderMenuItem({
    required String id,
    required FoodMenu menu,
    required int quantity,
    required int price,
    required int totalPrice,
  }) = _TransactionMenuItem;

  factory FoodOrderMenuItem.fromJson(Map<String, dynamic> json) =>
      _$FoodOrderMenuItemFromJson(json);
}
