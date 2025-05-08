import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/transaction/model/transaction_insight.dart';
import 'package:socieaty/features/transaction/repository/request/get-transactions-insight-request-query.dart';
import 'package:socieaty/features/transaction/repository/response/get_transactions_insight_response.dart';
import 'package:socieaty/features/transaction/repository/transaction_repository.dart';

part 'get_transaction_insight_data_provider.g.dart';

@riverpod
Future<TransactionInsight> getTransactionInsight(
  Ref ref,
  GetTransactionsInsightRequestQuery requestQuery,
) async {
  final transactionRepository = ref.watch(transactionRepositoryProvider);
  final result = await transactionRepository.getTransactionsInsight(requestQuery);
  switch(result){
    case Success<GetTransactionsInsightResponse>(data: final data):
      return data.transactionInsight;
    case Error(error: final error):
      throw Exception(error.message);
  }
}