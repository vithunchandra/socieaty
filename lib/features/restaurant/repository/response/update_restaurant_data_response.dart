import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';

part 'update_restaurant_data_response.freezed.dart';
part 'update_restaurant_data_response.g.dart';

@freezed
class UpdateRestaurantDataResponse with _$UpdateRestaurantDataResponse {
  const factory UpdateRestaurantDataResponse({
    @SocieatyRestaurantConverter() required SocieatyRestaurant restaurant,
  }) = _UpdateRestaurantDataResponse;

  factory UpdateRestaurantDataResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateRestaurantDataResponseFromJson(json);
}
