import 'package:freezed_annotation/freezed_annotation.dart';

part 'track_order_transaction_response.g.dart';
part 'track_order_transaction_response.freezed.dart';

@freezed
class TrackOrderTransactionResponse with _$TrackOrderTransactionResponse {
  const factory TrackOrderTransactionResponse({
    required String message,
  }) = _TrackOrderTransactionResponse;

  factory TrackOrderTransactionResponse.fromJson(Map<String, dynamic> json) =>
      _$TrackOrderTransactionResponseFromJson(json);
}
