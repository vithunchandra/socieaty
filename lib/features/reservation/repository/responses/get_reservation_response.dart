import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/reservation/model/reservation.dart';

part 'get_reservation_response.freezed.dart';
part 'get_reservation_response.g.dart';

@freezed
class GetReservationResponse with _$GetReservationResponse {
  const factory GetReservationResponse({
    required Reservation reservation,
  }) = _GetReservationResponse;

  factory GetReservationResponse.fromJson(Map<String, dynamic> json) =>
      _$GetReservationResponseFromJson(json);
}