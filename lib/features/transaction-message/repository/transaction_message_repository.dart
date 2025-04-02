import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/api_client.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/utils/execute_request.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/transaction-message/repository/response/create_transaction_message_response.dart';
import 'package:socieaty/features/transaction-message/repository/response/track_transaction_message_response.dart';

part 'transaction_message_repository.g.dart';

@riverpod
TransactionMessageRepository transactionMessageRepository(Ref ref) {
  final AuthLocalRepository authLocalRepository = ref.watch(authLocalRepositoryProvider);
  final token = authLocalRepository.getToken();
  return TransactionMessageRepository(
    dio: ref.watch(apiClientProvider(url: AppConstants.socieatyBackendUrl, token: token)),
  );
}

class TransactionMessageRepository {
  final Dio _dio;
  TransactionMessageRepository({required Dio dio}) : _dio = dio;

  Future<ApiResult<CreateTransactionMessageResponse>> createTransactionMessage(
    String transactionId,
    String message,
  ) async {
    return executeRequest<CreateTransactionMessageResponse>(
      requestFunction: () => _dio.post('transactions/order/$transactionId/messages', data: {
        'message': message,
      }),
      successParser: (data) => CreateTransactionMessageResponse.fromJson(data),
    );
  }

  Future<ApiResult<TrackTransactionMessageResponse>> trackTransactionMessage(
    String transactionId,
  ) async {
    return executeRequest<TrackTransactionMessageResponse>(
      requestFunction: () => _dio.get('transactions/order/$transactionId/messages/track'),
      successParser: (data) => TrackTransactionMessageResponse.fromJson(data),
    );
  }
}
