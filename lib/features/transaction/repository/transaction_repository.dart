import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/api_client.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/utils/execute_request.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/transaction/customer/viewstate/create_transaction_form_state.dart';
import 'package:socieaty/features/transaction/model/food_order_transaction.dart';
import 'package:socieaty/features/transaction/repository/response/create_order_transaction_response.dart';
import 'package:socieaty/features/transaction/repository/response/track_order_transaction_response.dart';

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

  Future<ApiResult<CreateOrderTransactionResponse>> createOrderTransaction(
    CreateTransactionFormState data,
  ) async {
    return executeRequest<CreateOrderTransactionResponse>(
      requestFunction: () => _dio.post(
        'transactions/order',
        data: data.toJson(),
      ),
      successParser: (data) => CreateOrderTransactionResponse.fromJson(data),
    );
  }

  Future<ApiResult<FoodOrderTransaction>> getFoodOrderTransaction(String id) async {
    return executeRequest<FoodOrderTransaction>(
      requestFunction: () => _dio.get('transactions/order/$id'),
      successParser: (data) => FoodOrderTransaction.fromJson(data),
    );
  }

  Future<ApiResult<TrackOrderTransactionResponse>> trackOrderTransaction(String id) async {
    return executeRequest<TrackOrderTransactionResponse>(
      requestFunction: () => _dio.get('transactions/order/$id/track'),
      successParser: (data) => TrackOrderTransactionResponse.fromJson(data),
    );
  }
}
