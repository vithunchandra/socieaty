import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/restaurant_menu/model/restaurant_menu.dart';

part 'create_restaurant_menu_response.freezed.dart';
part 'create_restaurant_menu_response.g.dart';

@freezed
class CreateRestaurantMenuResponse with _$CreateRestaurantMenuResponse {
  const factory CreateRestaurantMenuResponse({
    required RestaurantMenu menu,
  }) = _CreateRestaurantMenuResponse;

  factory CreateRestaurantMenuResponse.fromJson(Map<String, dynamic> json) => _$CreateRestaurantMenuResponseFromJson(json);
}
