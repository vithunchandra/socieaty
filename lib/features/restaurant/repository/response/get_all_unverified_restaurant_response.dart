import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';

part 'get_all_unverified_restaurant_response.freezed.dart';
part 'get_all_unverified_restaurant_response.g.dart';

@freezed
class GetAllUnverifiedRestaurantResponse with _$GetAllUnverifiedRestaurantResponse {
  const factory GetAllUnverifiedRestaurantResponse({
    @SocieatyRestaurantConverter() required List<SocieatyRestaurant> restaurants,
  }) = _GetAllUnverifiedRestaurantResponse;

  factory GetAllUnverifiedRestaurantResponse.fromJson(Map<String, dynamic> json) => _$GetAllUnverifiedRestaurantResponseFromJson(json);
}
