import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/transaction/model/food_order_transaction_message.dart';

part 'create_food_order_transaction_message_response.freezed.dart';
part 'create_food_order_transaction_message_response.g.dart';

@freezed
class CreateFoodOrderTransactionMessageResponse with _$CreateFoodOrderTransactionMessageResponse {
  const factory CreateFoodOrderTransactionMessageResponse.success(
    FoodOrderTransactionMessage transactionMessage,
  ) = _CreateFoodOrderTransactionMessageResponse;

  factory CreateFoodOrderTransactionMessageResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateFoodOrderTransactionMessageResponseFromJson(json);
}
