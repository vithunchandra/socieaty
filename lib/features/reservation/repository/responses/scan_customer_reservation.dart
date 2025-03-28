import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/reservation/model/reservation.dart';

part 'scan_customer_reservation.freezed.dart';
part 'scan_customer_reservation.g.dart';

@freezed
class ScanCustomerReservationResponse with _$ScanCustomerReservationResponse {
  const factory ScanCustomerReservationResponse({
    required Reservation reservation,
  }) = _ScanCustomerReservationResponse;

  factory ScanCustomerReservationResponse.fromJson(Map<String, dynamic> json) =>
      _$ScanCustomerReservationResponseFromJson(json);
}