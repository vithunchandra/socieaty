import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/reservation/model/reservation.dart';

part 'get_restaurant_reservations_response.freezed.dart';
part 'get_restaurant_reservations_response.g.dart';

@freezed
class GetRestaurantReservationsResponse with _$GetRestaurantReservationsResponse {
  const factory GetRestaurantReservationsResponse({
    required List<Reservation> reservations,
  }) = _GetRestaurantReservationsResponse;

  factory GetRestaurantReservationsResponse.fromJson(Map<String, dynamic> json) =>
      _$GetRestaurantReservationsResponseFromJson(json);
}
