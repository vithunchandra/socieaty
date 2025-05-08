import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/transaction/model/transaction_chart.dart';
import 'package:socieaty/features/transaction/repository/request/get-transactions-chart-data-request-query.dart';
import 'package:socieaty/features/transaction/repository/response/get_transactions_chart_data_response.dart';
import 'package:socieaty/features/transaction/repository/transaction_repository.dart';

part 'get_transaction_chart_data_provider.g.dart';

@riverpod
Future<List<TransactionChart>> getTransactionChartData(
  Ref ref,
  GetTransactionsChartDataRequestQuery requestQuery,
) async {
  final transactionRepository = ref.watch(transactionRepositoryProvider);
  final result = await transactionRepository.getTransactionsChartData(requestQuery);
  switch (result) {
    case Success<GetTransactionsChartDataResponse>(data: final data):
      return data.chartData;
    case Error(error: final error):
      throw Exception(error.message);
  }
}