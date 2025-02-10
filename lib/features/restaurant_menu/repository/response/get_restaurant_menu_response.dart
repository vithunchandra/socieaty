import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/restaurant_menu/model/restaurant_menu.dart';

part 'get_restaurant_menu_response.freezed.dart';
part 'get_restaurant_menu_response.g.dart';

@freezed
class GetRestaurantMenuResponse with _$GetRestaurantMenuResponse {
  const factory GetRestaurantMenuResponse({required RestaurantMenu menu}) =
      _GetRestaurantMenuResponse;

  factory GetRestaurantMenuResponse.fromJson(Map<String, dynamic> json) =>
      _$GetRestaurantMenuResponseFromJson(json);
}
