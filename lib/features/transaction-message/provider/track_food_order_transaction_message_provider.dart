import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/transaction-message/model/transaction_message.dart';
import 'package:socieaty/features/transaction-message/repository/transaction_message_repository.dart';
import 'package:socieaty/features/transaction-message/repository/response/track_transaction_message_response.dart';

part 'track_food_order_transaction_message_provider.g.dart';

@riverpod
Future<List<TransactionMessage>> trackTransactionMessage(
  Ref ref,
  String orderId,
) async {
  final foodOrderChatRepository = ref.watch(transactionMessageRepositoryProvider);
  final result = await foodOrderChatRepository.trackTransactionMessage(orderId);
  switch (result) {
    case Success(data: TrackTransactionMessageResponse data):
      return data.transactionMessages;
    case Error(error: final error):
      throw Exception(error.message);
  }
}
