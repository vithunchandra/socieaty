import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/reservation/model/reservation.dart';

part 'update_reservation_response.freezed.dart';
part 'update_reservation_response.g.dart';

@freezed
class UpdateReservationResponse with _$UpdateReservationResponse {
  const factory UpdateReservationResponse({
    required Reservation reservation,
  }) = _UpdateReservationResponse;

  factory UpdateReservationResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateReservationResponseFromJson(json);
}
