import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/food-order/model/food_order_transaction_message.dart';
import 'package:socieaty/shared/view_state.dart';

part 'chat_view_state.freezed.dart';

@freezed
class ChatViewState with _$ChatViewState {
  const factory ChatViewState({
    required ViewState<FoodOrderTransactionMessage> createdMessage,
  }) = _ChatViewState;
}
