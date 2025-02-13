import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/restaurant_menu/model/food_menu.dart';

part 'update_food_menu_response.freezed.dart';
part 'update_food_menu_response.g.dart';

@freezed
class UpdateFoodMenuResponse with _$UpdateFoodMenuResponse {
  const factory UpdateFoodMenuResponse({
    required FoodMenu menu,
  }) = _UpdateFoodMenuResponse;

  factory UpdateFoodMenuResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateFoodMenuResponseFromJson(json);
}
