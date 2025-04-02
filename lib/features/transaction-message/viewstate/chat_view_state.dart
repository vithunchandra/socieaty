import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/transaction-message/model/transaction_message.dart';

import 'package:socieaty/shared/view_state.dart';

part 'chat_view_state.freezed.dart';

@freezed
class ChatViewState with _$ChatViewState {
  const factory ChatViewState({
    required ViewState<TransactionMessage> createdMessage,
  }) = _ChatViewState;
}
