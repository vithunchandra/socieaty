import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/food-order/model/food_order_transaction.dart';

part 'get_food_order_transaction_response.g.dart';
part 'get_food_order_transaction_response.freezed.dart';

@freezed
class GetFoodOrderTransactionResponse with _$GetFoodOrderTransactionResponse {
  const factory GetFoodOrderTransactionResponse({
    required FoodOrderTransaction transaction,
  }) = _GetFoodOrderTransactionResponse;

  factory GetFoodOrderTransactionResponse.fromJson(Map<String, dynamic> json) =>
      _$GetFoodOrderTransactionResponseFromJson(json);
}
