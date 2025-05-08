import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/api_client.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/utils/execute_request.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/transaction/repository/request/get-transactions-chart-data-request-query.dart';
import 'package:socieaty/features/transaction/repository/request/get-transactions-insight-request-query.dart';
import 'package:socieaty/features/transaction/repository/request/paginate_transactions_request_query.dart';
import 'package:socieaty/features/transaction/repository/response/get_transactions_chart_data_response.dart';
import 'package:socieaty/features/transaction/repository/response/get_transactions_insight_response.dart';
import 'package:socieaty/features/transaction/repository/response/paginate_transactions_response.dart';

part 'transaction_repository.g.dart';

@riverpod
TransactionRepository transactionRepository(Ref ref) {
  final AuthLocalRepository authLocalRepository = ref.watch(authLocalRepositoryProvider);
  final token = authLocalRepository.getToken();
  return TransactionRepository(
    dio: ref.watch(apiClientProvider(url: AppConstants.socieatyBackendUrl, token: token)),
  );
}

class TransactionRepository {
  final Dio _dio;

  TransactionRepository({required Dio dio}) : _dio = dio;

  Future<ApiResult<PaginateTransactionsResponse>> paginateTransactions(
    PaginateTransactionsRequestQuery requestQuery,
  ) async {
    final queryData = {
      'paginationQuery': requestQuery.paginationQuery.toJson(),
      'searchQuery': requestQuery.searchQuery,
      'customerId': requestQuery.customerId,
      'restaurantId': requestQuery.restaurantId,
      'createdAt': requestQuery.rangeStartDate,
      'finishedAt': requestQuery.rangeEndDate,
      'serviceType': requestQuery.serviceType?.name,
      'status[]':
          List.generate(requestQuery.status.length, (index) => requestQuery.status[index].name),
      'sortBy': requestQuery.sortOrder?.name,
      'sortOrder': requestQuery.sortDirection?.name,
    };

    return executeRequest<PaginateTransactionsResponse>(
      requestFunction: () => _dio.get('transactions', queryParameters: queryData),
      successParser: (data) {
        debugPrint(data.toString());
        return PaginateTransactionsResponse.fromJson(data);
      },
    );
  }

  Future<ApiResult<GetTransactionsChartDataResponse>> getTransactionsChartData(
    GetTransactionsChartDataRequestQuery requestQuery,
  ) async {
    final queryData = {
      'restaurantId': requestQuery.restaurantId,
      'timeScale': requestQuery.timeScale.name,
      'rangeStartDate': requestQuery.rangeStartDate,
      'rangeEndDate': requestQuery.rangeEndDate,
    };

    return executeRequest<GetTransactionsChartDataResponse>(
      requestFunction: () => _dio.get('transactions/chart', queryParameters: queryData),
      successParser: (data) => GetTransactionsChartDataResponse.fromJson(data),
    );
  }

  Future<ApiResult<GetTransactionsInsightResponse>> getTransactionsInsight(
    GetTransactionsInsightRequestQuery requestQuery,
  ) async {
    final queryData = {
      'restaurantId': requestQuery.restaurantId,
      'rangeStartDate': requestQuery.rangeStartDate,
      'rangeEndDate': requestQuery.rangeEndDate,
      'serviceType': requestQuery.serviceType?.name,
    };

    return executeRequest<GetTransactionsInsightResponse>(
      requestFunction: () => _dio.get('transactions/insight', queryParameters: queryData),
      successParser: (data) => GetTransactionsInsightResponse.fromJson(data),
    );
  }
}
