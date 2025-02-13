import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/restaurant_menu/model/food_menu.dart';

part 'create_food_menu_response.freezed.dart';
part 'create_food_menu_response.g.dart';

@freezed
class CreateFoodMenuResponse with _$CreateFoodMenuResponse {
  const factory CreateFoodMenuResponse({
    required FoodMenu menu,
  }) = _CreateFoodMenuResponse;

  factory CreateFoodMenuResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateFoodMenuResponseFromJson(json);
}
