import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/restaurant/model/reservation_config.dart';

part 'create_reservation_config_response.freezed.dart';
part 'create_reservation_config_response.g.dart';

@freezed
class CreateReservationConfigResponse with _$CreateReservationConfigResponse {
  const factory CreateReservationConfigResponse({
    required ReservationConfig reservationConfig,
  }) = _CreateReservationConfigResponse;

  factory CreateReservationConfigResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateReservationConfigResponseFromJson(json);
}
