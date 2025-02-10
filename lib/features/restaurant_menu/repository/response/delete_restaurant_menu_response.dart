
import 'package:freezed_annotation/freezed_annotation.dart';

part 'delete_restaurant_menu_response.freezed.dart';
part 'delete_restaurant_menu_response.g.dart';

@freezed
class DeleteRestaurantMenuResponse with _$DeleteRestaurantMenuResponse {
  const factory DeleteRestaurantMenuResponse({
    required String message,
  }) = _DeleteRestaurantMenuResponse;

  factory DeleteRestaurantMenuResponse.fromJson(Map<String, dynamic> json) => _$DeleteRestaurantMenuResponseFromJson(json);

}
