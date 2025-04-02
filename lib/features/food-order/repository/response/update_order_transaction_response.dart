import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/food-order/model/food_order_transaction.dart';

part 'update_order_transaction_response.freezed.dart';
part 'update_order_transaction_response.g.dart';

@freezed
class UpdateOrderTransactionResponse with _$UpdateOrderTransactionResponse {
  const factory UpdateOrderTransactionResponse({
    required FoodOrderTransaction transaction,
  }) = _UpdateOrderTransactionResponse;

  factory UpdateOrderTransactionResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateOrderTransactionResponseFromJson(json);
}
