import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/restaurant_menu/model/menu_category.dart';

part 'restaurant_menu.freezed.dart';
part 'restaurant_menu.g.dart';

@freezed
class RestaurantMenu with _$RestaurantMenu {
  const factory RestaurantMenu({
    required String id,
    required String restaurantId,
    required String name,
    required int price,
    required String description,
    required String pictureUrl,
    required int estimatedTime,
    required bool isStockAvailable,
    required List<MenuCategory> categories,
  }) = _RestaurantMenu;

  factory RestaurantMenu.fromJson(Map<String, dynamic> json) => _$RestaurantMenuFromJson(json);
}
