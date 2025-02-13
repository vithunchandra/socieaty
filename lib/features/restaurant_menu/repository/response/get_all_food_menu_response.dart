import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/restaurant_menu/model/food_menu.dart';

part 'get_all_food_menu_response.freezed.dart';
part 'get_all_food_menu_response.g.dart';

@freezed
class GetAllFoodMenuResponse with _$GetAllFoodMenuResponse {
  const factory GetAllFoodMenuResponse({
    required List<FoodMenu> menus,
  }) = _GetAllFoodMenuResponse;

  factory GetAllFoodMenuResponse.fromJson(Map<String, dynamic> json) =>
      _$GetAllFoodMenuResponseFromJson(json);
}
