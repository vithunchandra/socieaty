import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/food-order/model/food_order_transaction.dart';
import 'package:socieaty/shared/models/pagination_query.dart';

part 'paginate_orders_response.freezed.dart';
part 'paginate_orders_response.g.dart';

@freezed
class PaginateOrdersResponse with _$PaginateOrdersResponse {
  const factory PaginateOrdersResponse({
    required List<FoodOrderTransaction> items,
    required PaginationQuery pagination,
  }) = _PaginateOrdersResponse;

  factory PaginateOrdersResponse.fromJson(Map<String, dynamic> json) =>
      _$PaginateOrdersResponseFromJson(json);
}
