import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/api_client.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/utils/execute_request.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/transaction_review/repository/response/create_transaction_review_response.dart';
import 'package:socieaty/features/transaction_review/viewstate/create_transaction_review_form_state.dart';

part 'transaction_review_repository.g.dart';

@riverpod
TransactionReviewRepository transactionReviewRepository(Ref ref) {
  final AuthLocalRepository authLocalRepository = ref.watch(authLocalRepositoryProvider);
  final token = authLocalRepository.getToken();
  return TransactionReviewRepository(
    dio: ref.watch(apiClientProvider(url: AppConstants.socieatyBackendUrl, token: token)),
  );
}

class TransactionReviewRepository {
  final Dio _dio;
  TransactionReviewRepository({required Dio dio}) : _dio = dio;

  Future<ApiResult<CreateTransactionReviewResponse>> createTransactionReview(
    String transactionId,
    CreateTransactionReviewFormState data,
  ) async {
    return executeRequest<CreateTransactionReviewResponse>(
      requestFunction: () => _dio.post('transactions/$transactionId/review', data: data.toJson()),
      successParser: (data) => CreateTransactionReviewResponse.fromJson(data),
    );
  }
}
