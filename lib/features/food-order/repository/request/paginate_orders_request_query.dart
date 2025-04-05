

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/core/enums/sort_order_enum.dart';
import 'package:socieaty/features/food-order/enum/food_order_sort_by_enum.dart';
import 'package:socieaty/features/food-order/enum/food_order_status_enum.dart';
import 'package:socieaty/shared/models/pagination_query.dart';

part 'paginate_orders_request_query.freezed.dart';
part 'paginate_orders_request_query.g.dart';

@freezed
class PaginateOrdersRequestQuery with _$PaginateOrdersRequestQuery {
  const factory PaginateOrdersRequestQuery({
    @Default(null) String? customerId,
    @Default(null) String? restaurantId,
    @Default(null) DateTime? createdAt,
    @Default(null) DateTime? finishedAt,
    @Default([]) List<FoodOrderStatus> status,
    @Default(null) FoodOrderSortBy? sortBy,
    @Default(null) SortOrder? sortOrder,
    required PaginationQuery paginationQuery,
  }) = _PaginateOrdersRequestQuery;

  factory PaginateOrdersRequestQuery.fromJson(Map<String, dynamic> json) =>
      _$PaginateOrdersRequestQueryFromJson(json);
}
