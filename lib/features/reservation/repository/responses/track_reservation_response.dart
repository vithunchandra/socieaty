import 'package:freezed_annotation/freezed_annotation.dart';

part 'track_reservation_response.freezed.dart';
part 'track_reservation_response.g.dart';

@freezed
class TrackReservationResponse with _$TrackReservationResponse {
  const factory TrackReservationResponse({
    required String message,
  }) = _TrackReservationResponse;

  factory TrackReservationResponse.fromJson(Map<String, dynamic> json) => _$TrackReservationResponseFromJson(json);
}
