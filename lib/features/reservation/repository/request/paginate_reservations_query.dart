import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/enums/sort_order_enum.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/reservation/enum/reservation_sort_by_enum.dart';
import 'package:socieaty/features/reservation/enum/reservation_status_enum.dart';
import 'package:socieaty/shared/models/pagination_query.dart';

part 'paginate_reservations_query.freezed.dart';
part 'paginate_reservations_query.g.dart';

@freezed
class PaginateReservationsQuery with _$PaginateReservationsQuery {
  const factory PaginateReservationsQuery({
    @Default(null) String? customerId,
    @Default(null) String? restaurantId,
    @Default(null) DateTime? createdAt,
    @Default(null) DateTime? finishedAt,
    @Default(null) DateTime? reservationTime,
    @ListReservationStatusConverter() @Default([]) List<ReservationStatus> reservationStatus,
    @ReservationSortByConverter() @Default(null) ReservationSortBy? sortBy,
    @SortOrderConverter() @Default(null) SortOrder? sortOrder,
    @Default(PaginationQuery(page: 0, pageSize: 5)) PaginationQuery paginationQuery,
  }) = _PaginateReservationsQuery;

  factory PaginateReservationsQuery.fromJson(Map<String, dynamic> json) =>
      _$PaginateReservationsQueryFromJson(json);
}
