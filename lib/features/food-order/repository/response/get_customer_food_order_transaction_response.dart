import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/food-order/model/food_order_transaction.dart';

part 'get_customer_food_order_transaction_response.freezed.dart';
part 'get_customer_food_order_transaction_response.g.dart';

@freezed
class GetCustomerFoodOrderTransactionResponse with _$GetCustomerFoodOrderTransactionResponse {
  const factory GetCustomerFoodOrderTransactionResponse({
    required List<FoodOrderTransaction> transactions,
  }) = _GetCustomerFoodOrderTransactionResponse;

  factory GetCustomerFoodOrderTransactionResponse.fromJson(Map<String, dynamic> json) =>
      _$GetCustomerFoodOrderTransactionResponseFromJson(json);
}
