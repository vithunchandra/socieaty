
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/transaction/model/food_order_transaction.dart';
import 'package:socieaty/features/transaction/repository/transaction_repository.dart';

part 'get_transaction_provider.g.dart';

@riverpod
Future<FoodOrderTransaction> getTransaction(Ref ref, String id) async {
  final repository = ref.read(transactionRepositoryProvider);
  final result = await repository.getFoodOrderTransaction(id);
  switch (result) {
    case Success(data: final data):
      return data;
    case Error(error: final error):
      throw Exception(error.message);
  }
}
