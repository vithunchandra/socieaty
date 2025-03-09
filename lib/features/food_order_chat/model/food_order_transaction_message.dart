import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';

part 'food_order_transaction_message.freezed.dart';
part 'food_order_transaction_message.g.dart';

@freezed
class FoodOrderTransactionMessage with _$FoodOrderTransactionMessage {
  const factory FoodOrderTransactionMessage.orderPlaced(
    String message,
    String transactionId,
    SocieatyUser user,
  ) = _FoodOrderTransactionMessage;

  factory FoodOrderTransactionMessage.fromJson(Map<String, dynamic> json) =>
      _$FoodOrderTransactionMessageFromJson(json);
}
