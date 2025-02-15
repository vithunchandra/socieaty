import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/food_menu/model/food_menu.dart';

part 'get_food_menu_response.freezed.dart';
part 'get_food_menu_response.g.dart';

@freezed
class GetFoodMenuResponse with _$GetFoodMenuResponse {
  const factory GetFoodMenuResponse({required FoodMenu menu}) = _GetFoodMenuResponse;

  factory GetFoodMenuResponse.fromJson(Map<String, dynamic> json) =>
      _$GetFoodMenuResponseFromJson(json);
}
