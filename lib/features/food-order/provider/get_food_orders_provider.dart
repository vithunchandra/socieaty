import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/food-order/model/food_order_transaction.dart';
import 'package:socieaty/features/food-order/repository/food_order_repository.dart';
import 'package:socieaty/features/food-order/repository/request/get_orders_request_query.dart';
import 'package:socieaty/features/food-order/repository/response/get_orders_response.dart';

part 'get_food_orders_provider.g.dart';

@riverpod
Future<List<FoodOrderTransaction>> getFoodOrders(Ref ref, {required GetOrdersRequestQuery query}) async {
  final repository = ref.watch(foodOrderRepositoryProvider);
  final result = await repository.getOrders(query);
  switch (result) {
    case Success<GetOrdersResponse>(data: final data):
      return data.orders;
    case Error(error: final error):
      throw Exception(error.message);
  }
}
