import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';

part 'transaction_message.freezed.dart';
part 'transaction_message.g.dart';

@freezed
class TransactionMessage with _$TransactionMessage {
  const factory TransactionMessage.orderPlaced(
    String message,
    String transactionId,
    SocieatyUser user,
  ) = _TransactionMessage;

  factory TransactionMessage.fromJson(Map<String, dynamic> json) =>
      _$TransactionMessageFromJson(json);
}
