import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/api_client.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/utils/execute_request.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/food_order_chat/repository/response/create_food_order_transaction_message_response.dart';
import 'package:socieaty/features/food_order_chat/repository/response/track_food_order_transaction_message_response.dart';

part 'food_order_chat_repository.g.dart';

@riverpod
FoodOrderChatRepository foodOrderChatRepository(Ref ref) {
  final AuthLocalRepository authLocalRepository = ref.watch(authLocalRepositoryProvider);
  final token = authLocalRepository.getToken();
  return FoodOrderChatRepository(
    dio: ref.watch(apiClientProvider(url: AppConstants.socieatyBackendUrl, token: token)),
  );
}

class FoodOrderChatRepository {
  final Dio _dio;
  FoodOrderChatRepository({required Dio dio}) : _dio = dio;

  Future<ApiResult<CreateFoodOrderTransactionMessageResponse>> createFoodOrderTransactionMessage(
    String transactionId,
    String message,
  ) async {
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
