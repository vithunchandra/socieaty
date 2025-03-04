import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/transaction/model/food_order_transaction.dart';
import 'package:socieaty/features/transaction/repository/transaction_repository.dart';

part 'get_restaurant_food_transaction_provider.g.dart';

@riverpod
Future<List<FoodOrderTransaction>> getRestaurantFoodTransaction(Ref ref, TransactionStatus status) async {
  final repository = ref.watch(transactionRepositoryProvider);
  final result = await repository.getRestaurantFoodTransaction(status);
  switch(result) {
    case Success(data: var data):
      return data.transactions;
    case Error(error: var error):
      throw error;
  }
}

