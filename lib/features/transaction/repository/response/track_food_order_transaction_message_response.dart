import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/transaction/model/food_order_transaction_message.dart';

part 'track_food_order_transaction_message_response.freezed.dart';
part 'track_food_order_transaction_message_response.g.dart';

@freezed
class TrackFoodOrderTransactionMessageResponse with _$TrackFoodOrderTransactionMessageResponse {
  const factory TrackFoodOrderTransactionMessageResponse({
    required List<FoodOrderTransactionMessage> transactionMessages,
  }) = _TrackFoodOrderTransactionMessageResponse;

  factory TrackFoodOrderTransactionMessageResponse.fromJson(Map<String, dynamic> json) =>
      _$TrackFoodOrderTransactionMessageResponseFromJson(json);
}
