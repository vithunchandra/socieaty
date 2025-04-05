import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/core/enums/sort_order_enum.dart';
import 'package:socieaty/features/food-order/enum/food_order_sort_by_enum.dart';
import 'package:socieaty/features/food-order/enum/food_order_status_enum.dart';

part 'get_orders_request_query.freezed.dart';
part 'get_orders_request_query.g.dart';

@freezed
class GetOrdersRequestQuery with _$GetOrdersRequestQuery {
  const factory GetOrdersRequestQuery({
    @Default(null) String? customerId,
    @Default(null) String? restaurantId,
    @Default(null) DateTime? createdAt,
    @Default(null) DateTime? finishedAt,
    @Default([]) List<FoodOrderStatus> status,
    @Default(null) FoodOrderSortBy? sortBy,
    @Default(null) SortOrder? sortOrder,
  }) = _GetOrdersRequestQuery;

  factory GetOrdersRequestQuery.fromJson(Map<String, dynamic> json) =>
      _$GetOrdersRequestQueryFromJson(json);
}
