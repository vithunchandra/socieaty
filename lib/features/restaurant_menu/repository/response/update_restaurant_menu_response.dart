import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/restaurant_menu/model/restaurant_menu.dart';

part 'update_restaurant_menu_response.freezed.dart';
part 'update_restaurant_menu_response.g.dart';

@freezed
class UpdateRestaurantMenuResponse with _$UpdateRestaurantMenuResponse {
  const factory UpdateRestaurantMenuResponse({
    required RestaurantMenu menu,
  }) = _UpdateRestaurantMenuResponse;

  factory UpdateRestaurantMenuResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateRestaurantMenuResponseFromJson(json);
}
