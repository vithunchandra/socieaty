import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/reservation/model/reservation.dart';

part 'create_reservation_response.freezed.dart';
part 'create_reservation_response.g.dart';

@freezed
class CreateReservationResponse with _$CreateReservationResponse {
  const factory CreateReservationResponse({
    required Reservation reservation,
  }) = _CreateReservationResponse;

  factory CreateReservationResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateReservationResponseFromJson(json);
}