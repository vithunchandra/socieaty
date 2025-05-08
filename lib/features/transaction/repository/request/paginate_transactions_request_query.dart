import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/core/enums/sort_order_enum.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/shared/models/pagination_query.dart';

part 'paginate_transactions_request_query.freezed.dart';
part 'paginate_transactions_request_query.g.dart';

@freezed
class PaginateTransactionsRequestQuery with _$PaginateTransactionsRequestQuery {
  const factory PaginateTransactionsRequestQuery({
    required PaginationQuery paginationQuery,
    @Default(null) String? searchQuery,
    @Default(null) String? customerId,
    @Default(null) String? restaurantId,
    @Default(null) DateTime? rangeStartDate,
    @Default(null) DateTime? rangeEndDate,
    @TransactionServiceTypeConverter() @Default(null) TransactionServiceType? serviceType,
    @TransactionStatusConverter() @Default([]) List<TransactionStatus> status,
    @Default(null) @TransactionSortByConverter() TransactionSortBy? sortOrder,
    @Default(null) @SortOrderConverter() SortOrder? sortDirection,
  }) = _PaginateTransactionsRequestQuery;

  factory PaginateTransactionsRequestQuery.fromJson(Map<String, dynamic> json) =>
      _$PaginateTransactionsRequestQueryFromJson(json);
}
