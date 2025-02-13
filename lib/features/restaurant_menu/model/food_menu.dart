import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/restaurant_menu/model/menu_category.dart';

part 'food_menu.freezed.dart';
part 'food_menu.g.dart';

@freezed
class FoodMenu with _$FoodMenu {
  const factory FoodMenu({
    required String id,
    required String restaurantId,
    required String name,
    required int price,
    required String description,
    required String pictureUrl,
    required int estimatedTime,
    required bool isStockAvailable,
    required List<MenuCategory> categories,
  }) = _FoodMenu;

  factory FoodMenu.fromJson(Map<String, dynamic> json) => _$FoodMenuFromJson(json);
}
