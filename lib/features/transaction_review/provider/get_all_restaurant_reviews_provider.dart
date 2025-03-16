import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/transaction_review/model/transaction_review.dart';
import 'package:socieaty/features/transaction_review/repository/transaction_review_repository.dart';
import 'package:socieaty/features/transaction_review/viewstate/get_restaurant_reviews_query.dart';

part 'get_all_restaurant_reviews_provider.g.dart';

@riverpod
Future<List<TransactionReview>> getAllRestaurantReviews(Ref ref, String restaurantId, GetRestaurantReviewsQuery? query) async {
  final transactionReviewRepository = ref.watch(transactionReviewRepositoryProvider);
  final result = await transactionReviewRepository.getAllRestaurantTransactionReviews(restaurantId, query);
  switch (result) {
    case Success(data: final data):
      return data.reviews;
    case Error(error: final error):
      throw Exception(error.message);
  }
}
