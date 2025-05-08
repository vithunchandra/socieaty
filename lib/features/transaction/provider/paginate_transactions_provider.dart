import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/transaction/repository/request/paginate_transactions_request_query.dart';
import 'package:socieaty/features/transaction/repository/response/paginate_transactions_response.dart';
import 'package:socieaty/features/transaction/repository/transaction_repository.dart';

Future<PaginateTransactionsResponse> paginateTransactions(
    WidgetRef ref, PaginateTransactionsRequestQuery query) async {
  final result = await ref.read(transactionRepositoryProvider).paginateTransactions(query);
  switch (result) {
    case Success<PaginateTransactionsResponse>(data: final data):
      return data;
    case Error(error: final error):
      throw Exception(error.message);
  }
}
