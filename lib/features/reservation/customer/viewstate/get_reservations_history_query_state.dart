import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/core/enums/sort_order_enum.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/reservation/enum/reservation_sort_by_enum.dart';
import 'package:socieaty/features/reservation/enum/reservation_status_enum.dart';

part 'get_reservations_history_query_state.freezed.dart';
part 'get_reservations_history_query_state.g.dart';

@freezed
class GetReservationsHistoryQueryState with _$GetReservationsHistoryQueryState {
  factory GetReservationsHistoryQueryState({
    @ReservationStatusConverter() required List<ReservationStatus> reservationStatus,
    @ReservationSortByConverter() @Default(null) ReservationSortBy? sortBy,
    @SortOrderConverter() @Default(null) SortOrder? sortOrder,
    @Default(false) bool isLoading,
  }) = _GetReservationsHistoryQueryState;

  factory GetReservationsHistoryQueryState.fromJson(Map<String, dynamic> json) =>
      _$GetReservationsHistoryQueryStateFromJson(json);
}
