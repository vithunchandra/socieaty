import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/food-order/model/food_order_transaction.dart';
import 'package:socieaty/features/food-order/repository/food_order_repository.dart';

part 'get_restaurant_food_order_provider.g.dart';

@riverpod
Future<List<FoodOrderTransaction>> getRestaurantFoodOrder(
    Ref ref, List<FoodOrderStatus> status) async {
  final repository = ref.watch(foodOrderRepositoryProvider);
  final result = await repository.getRestaurantFoodTransaction(status);
  debugPrint(result.toString());

  switch (result) {
    case Success(data: var data):
      return data.transactions;
    case Error(error: var error):
      throw error;
  }
}
