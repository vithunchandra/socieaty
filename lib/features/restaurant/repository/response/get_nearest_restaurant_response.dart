import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';

part 'get_nearest_restaurant_response.freezed.dart';
part 'get_nearest_restaurant_response.g.dart';

@freezed
class GetNearestRestaurantResponse with _$GetNearestRestaurantResponse {
  const factory GetNearestRestaurantResponse({
    @Default([]) List<SocieatyRestaurant> restaurants,
  }) = _GetNearestRestaurantResponse;

  factory GetNearestRestaurantResponse.fromJson(Map<String, dynamic> json) =>
      _$GetNearestRestaurantResponseFromJson(json);
}
