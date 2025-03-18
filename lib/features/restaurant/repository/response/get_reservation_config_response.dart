import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/restaurant/model/reservation_config.dart';

part 'get_reservation_config_response.freezed.dart';
part 'get_reservation_config_response.g.dart';

@freezed
class GetReservationConfigResponse with _$GetReservationConfigResponse {
  const factory GetReservationConfigResponse({
    ReservationConfig? reservationConfig,
  }) = _GetReservationConfigResponse;

  factory GetReservationConfigResponse.fromJson(Map<String, dynamic> json) =>
      _$GetReservationConfigResponseFromJson(json);
}
