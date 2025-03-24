import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/restaurant/model/reservation_config.dart';

part 'update_reservation_config_response.freezed.dart';
part 'update_reservation_config_response.g.dart';

@freezed
class UpdateReservationConfigResponse with _$UpdateReservationConfigResponse {
  const factory UpdateReservationConfigResponse({
    required ReservationConfig updatedConfig,
  }) = _UpdateReservationConfigResponse;

  factory UpdateReservationConfigResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateReservationConfigResponseFromJson(json);
}
