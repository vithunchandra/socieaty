import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/restaurant_menu/model/restaurant_menu.dart';

part 'update_restaurant_menu_stock_availablity.freezed.dart';
part 'update_restaurant_menu_stock_availablity.g.dart';

@freezed
class UpdateRestaurantMenuStockAvailabilityResponse
    with _$UpdateRestaurantMenuStockAvailabilityResponse {
  const factory UpdateRestaurantMenuStockAvailabilityResponse({
    required RestaurantMenu updatedMenu,
  }) = _UpdateRestaurantMenuStockAvailabilityResponse;

  factory UpdateRestaurantMenuStockAvailabilityResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateRestaurantMenuStockAvailabilityResponseFromJson(json);
}
