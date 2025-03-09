import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/transaction/model/food_order_transaction_message.dart';
import 'package:socieaty/features/transaction/repository/response/track_food_order_transaction_message_response.dart';
import 'package:socieaty/features/transaction/repository/transaction_repository.dart';

part 'track_food_order_transaction_message_provider.g.dart';

@riverpod
Future<List<FoodOrderTransactionMessage>> trackFoodOrderTransactionMessage(
  Ref ref,
  String orderId,
) async {
  final transactionRepository = ref.watch(transactionRepositoryProvider);
  final result = await transactionRepository.trackFoodOrderTransactionMessage(orderId);
  switch (result) {
    case Success(data: TrackFoodOrderTransactionMessageResponse data):
      return data.transactionMessages;
    case Error(error: final error):
      throw Exception(error.message);
  }
}