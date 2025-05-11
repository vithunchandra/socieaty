import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';

part 'toggle_reservation_availability_response.g.dart';
part 'toggle_reservation_availability_response.freezed.dart';

@freezed
class ToggleReservationAvailabilityResponse with _$ToggleReservationAvailabilityResponse {
  const factory ToggleReservationAvailabilityResponse({
    @SocieatyRestaurantConverter() required SocieatyRestaurant restaurant,
  }) = _ToggleReservationAvailabilityResponse;

  factory ToggleReservationAvailabilityResponse.fromJson(Map<String, dynamic> json) =>
      _$ToggleReservationAvailabilityResponseFromJson(json);
}
