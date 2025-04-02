import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/food-order/model/food_order_transaction.dart';

part 'get_restaurant_food_transaction_response.freezed.dart';
part 'get_restaurant_food_transaction_response.g.dart';

@freezed
class GetRestaurantFoodTransactionResponse with _$GetRestaurantFoodTransactionResponse {
  factory GetRestaurantFoodTransactionResponse({
    required List<FoodOrderTransaction> transactions,
  }) = _GetRestaurantFoodTransactionResponse;

  factory GetRestaurantFoodTransactionResponse.fromJson(Map<String, dynamic> json) =>
      _$GetRestaurantFoodTransactionResponseFromJson(json);
}
