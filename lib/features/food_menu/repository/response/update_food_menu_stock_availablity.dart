import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/food_menu/model/food_menu.dart';

part 'update_food_menu_stock_availablity.freezed.dart';
part 'update_food_menu_stock_availablity.g.dart';

@freezed
class UpdateFoodMenuStockAvailabilityResponse with _$UpdateFoodMenuStockAvailabilityResponse {
  const factory UpdateFoodMenuStockAvailabilityResponse({
    required FoodMenu updatedMenu,
  }) = _UpdateFoodMenuStockAvailabilityResponse;

  factory UpdateFoodMenuStockAvailabilityResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateFoodMenuStockAvailabilityResponseFromJson(json);
}
