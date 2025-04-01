import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/food-order/model/food_order_transaction.dart';
import 'package:socieaty/features/food-order/repository/food_order_repository.dart';

part 'get_food_order_provider.g.dart';

@riverpod
Future<FoodOrderTransaction> getFoodOrder(Ref ref, String id) async {
  final repository = ref.read(foodOrderRepositoryProvider);
  final result = await repository.getFoodOrderTransaction(id);
  switch (result) {
    case Success(data: final data):
      return data.transaction;
    case Error(error: final error):
      throw Exception(error.message);
  }
}
