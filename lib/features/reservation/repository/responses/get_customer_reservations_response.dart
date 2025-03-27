import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/reservation/model/reservation.dart';

part 'get_customer_reservations_response.freezed.dart';
part 'get_customer_reservations_response.g.dart';

@freezed
class GetCustomerReservationsResponse with _$GetCustomerReservationsResponse {
  const factory GetCustomerReservationsResponse({
    required List<Reservation> reservations,
  }) = _GetCustomerReservationsResponse;

  factory GetCustomerReservationsResponse.fromJson(Map<String, dynamic> json) =>
      _$GetCustomerReservationsResponseFromJson(json);
}
