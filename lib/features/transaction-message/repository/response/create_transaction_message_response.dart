import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/transaction-message/model/transaction_message.dart';

part 'create_transaction_message_response.freezed.dart';
part 'create_transaction_message_response.g.dart';

@freezed
class CreateTransactionMessageResponse with _$CreateTransactionMessageResponse {
  const factory CreateTransactionMessageResponse.success(
    TransactionMessage transactionMessage,
  ) = _CreateTransactionMessageResponse;

  factory CreateTransactionMessageResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateTransactionMessageResponseFromJson(json);
}
