import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/food-order/model/food_order_transaction.dart';

part 'get_orders_response.freezed.dart';
part 'get_orders_response.g.dart';

@freezed
class GetOrdersResponse with _$GetOrdersResponse {
  const factory GetOrdersResponse({
    required List<FoodOrderTransaction> orders,
  }) = _GetOrdersResponse;

  factory GetOrdersResponse.fromJson(Map<String, dynamic> json) =>
      _$GetOrdersResponseFromJson(json);
}
