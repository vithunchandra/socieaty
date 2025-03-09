import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/core/network/api_client.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/utils/execute_request.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/transaction/customer/viewstate/create_transaction_form_state.dart';
import 'package:socieaty/features/transaction/model/food_order_transaction.dart';
import 'package:socieaty/features/transaction/repository/response/create_food_order_transaction_response.dart';
import 'package:socieaty/features/transaction/repository/response/create_order_transaction_response.dart';
import 'package:socieaty/features/transaction/repository/response/get_restaurant_food_transaction_response.dart';
import 'package:socieaty/features/transaction/repository/response/track_food_order_transaction_message_response.dart';
import 'package:socieaty/features/transaction/repository/response/track_order_transaction_response.dart';
import 'package:socieaty/features/transaction/repository/response/update_order_transaction_response.dart';

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

  Future<ApiResult<GetRestaurantFoodTransactionResponse>> getRestaurantFoodTransaction(
      List<TransactionStatus> status) async {
    return executeRequest<GetRestaurantFoodTransactionResponse>(
      requestFunction: () => _dio.get('transactions/order/restaurant', queryParameters: {
        'status[]': List.generate(status.length, (index) => status[index].name),
      }),
      successParser: (data) => GetRestaurantFoodTransactionResponse.fromJson(data),
    );
  }

  Future<ApiResult<UpdateOrderTransactionResponse>> updateTransactionStatus(
      String id, TransactionStatus status) async {
    return executeRequest<UpdateOrderTransactionResponse>(
      requestFunction: () => _dio.put('transactions/order/$id/', data: {'status': status.name}),
      successParser: (data) => UpdateOrderTransactionResponse.fromJson(data),
    );
  }

  Future<ApiResult<CreateFoodOrderTransactionMessageResponse>> createFoodOrderTransactionMessage(
    String transactionId,
    String message,
  ) async {
    debugPrint("Hallo");
    return executeRequest<CreateFoodOrderTransactionMessageResponse>(
      requestFunction: () => _dio.post('transactions/order/$transactionId/messages', data: {
        'message': message,
      }),
      successParser: (data) => CreateFoodOrderTransactionMessageResponse.fromJson(data),
    );
  }

  Future<ApiResult<TrackFoodOrderTransactionMessageResponse>> trackFoodOrderTransactionMessage(
    String transactionId,
  ) async {
    return executeRequest<TrackFoodOrderTransactionMessageResponse>(
      requestFunction: () => _dio.get('transactions/order/$transactionId/messages/track'),
      successParser: (data) => TrackFoodOrderTransactionMessageResponse.fromJson(data),
    );
  }
}
