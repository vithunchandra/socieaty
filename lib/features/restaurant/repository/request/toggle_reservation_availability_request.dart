import 'package:freezed_annotation/freezed_annotation.dart';

part 'toggle_reservation_availability_request.freezed.dart';
part 'toggle_reservation_availability_request.g.dart';

@freezed
class ToggleReservationAvailabilityRequest with _$ToggleReservationAvailabilityRequest {
  const factory ToggleReservationAvailabilityRequest({
    required bool value,
  }) = _ToggleReservationAvailabilityRequest;

  factory ToggleReservationAvailabilityRequest.fromJson(Map<String, dynamic> json) =>
      _$ToggleReservationAvailabilityRequestFromJson(json);
}