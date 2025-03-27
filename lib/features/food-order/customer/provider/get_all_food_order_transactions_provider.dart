import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/food-order/enum/food_order_status_enum.dart';
import 'package:socieaty/features/food-order/model/food_order_transaction.dart';
import 'package:socieaty/features/food-order/repository/food_order_repository.dart';

part 'get_all_food_order_transactions_provider.g.dart';

@riverpod
Future<List<FoodOrderTransaction>> getAllFoodOrderTransactions(
    Ref ref, List<FoodOrderStatus> status) async {
  final repository = ref.watch(foodOrderRepositoryProvider);
  final result = await repository.getAllCustomerFoodOrderTransaction(status);
  switch (result) {
    case Success(data: final data):
      return data.transactions;
    case Error(error: final error):
      throw Exception(error.message);
  }
}
