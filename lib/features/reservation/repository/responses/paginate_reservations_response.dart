import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/reservation/model/reservation.dart';
import 'package:socieaty/shared/models/pagination.dart';

part 'paginate_reservations_response.freezed.dart';
part 'paginate_reservations_response.g.dart';

@freezed
class PaginateReservationsResponse with _$PaginateReservationsResponse {
  const factory PaginateReservationsResponse({
    @Default([]) List<Reservation> items,
    required Pagination pagination,
  }) = _PaginateReservationsResponse;

  factory PaginateReservationsResponse.fromJson(Map<String, dynamic> json) => _$PaginateReservationsResponseFromJson(json);
}


