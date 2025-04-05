import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/reservation/model/reservation.dart';
import 'package:socieaty/shared/models/pagination.dart';

part 'get_reservations_response.freezed.dart';
part 'get_reservations_response.g.dart';

@freezed
class GetReservationsResponse with _$GetReservationsResponse {
  const factory GetReservationsResponse({
    @Default([]) List<Reservation> reservations,
  }) = _GetReservationsResponse;

  factory GetReservationsResponse.fromJson(Map<String, dynamic> json) => _$GetReservationsResponseFromJson(json);

}