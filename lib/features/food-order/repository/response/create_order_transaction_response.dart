import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/food-order/model/food_order_transaction.dart';

part 'create_order_transaction_response.freezed.dart';
part 'create_order_transaction_response.g.dart';

@freezed
class CreateOrderTransactionResponse with _$CreateOrderTransactionResponse {
  const factory CreateOrderTransactionResponse({
    required FoodOrderTransaction transaction,
  }) = _CreateOrderTransactionResponse;

  factory CreateOrderTransactionResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderTransactionResponseFromJson(json);
}

