import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/transaction_review/model/transaction_review.dart';
import 'package:socieaty/features/transaction_review/repository/transaction_review_repository.dart';

part 'get_transaction_review_provider.g.dart';

@riverpod
Future<TransactionReview> getTransactionReview(Ref ref, String transactionId) async {
  final transactionReviewRepository = ref.watch(transactionReviewRepositoryProvider);
  final result = await transactionReviewRepository.getTransactionReview(transactionId);
  switch (result) {
    case Success(data: final data):
      return data.review;
    case Error(error: final error):
      throw Exception(error.message);
  }
}
