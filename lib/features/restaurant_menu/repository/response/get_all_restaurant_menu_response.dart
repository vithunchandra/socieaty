import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/restaurant_menu/model/restaurant_menu.dart';

part 'get_all_restaurant_menu_response.freezed.dart';
part 'get_all_restaurant_menu_response.g.dart';

@freezed
class GetAllRestaurantMenuResponse with _$GetAllRestaurantMenuResponse {
  const factory GetAllRestaurantMenuResponse({
    required List<RestaurantMenu> menus,
  }) = _GetAllRestaurantMenuResponse;

  factory GetAllRestaurantMenuResponse.fromJson(Map<String, dynamic> json) =>
      _$GetAllRestaurantMenuResponseFromJson(json);
}
