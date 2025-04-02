import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/transaction-message/model/transaction_message.dart';


part 'track_transaction_message_response.freezed.dart';
part 'track_transaction_message_response.g.dart';

@freezed
class TrackTransactionMessageResponse with _$TrackTransactionMessageResponse {
  const factory TrackTransactionMessageResponse({
    required List<TransactionMessage> transactionMessages,
  }) = _TrackTransactionMessageResponse;

  factory TrackTransactionMessageResponse.fromJson(Map<String, dynamic> json) =>
      _$TrackTransactionMessageResponseFromJson(json);
}
