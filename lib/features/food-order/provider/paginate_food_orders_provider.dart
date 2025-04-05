import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/food-order/repository/food_order_repository.dart';
import 'package:socieaty/features/food-order/repository/request/paginate_orders_request_query.dart';
import 'package:socieaty/features/food-order/repository/response/paginate_orders_response.dart';

part 'paginate_food_orders_provider.g.dart';

@riverpod
Future<PaginateOrdersResponse> paginateFoodOrders(Ref ref, {required PaginateOrdersRequestQuery query}) async {
  final repository = ref.watch(foodOrderRepositoryProvider);
  final result = await repository.paginateOrders(query);
  switch (result) {
    case Success<PaginateOrdersResponse>(data: final data):
      return data;
    case Error(error: final error):
      throw Exception(error.message);
  }
}

