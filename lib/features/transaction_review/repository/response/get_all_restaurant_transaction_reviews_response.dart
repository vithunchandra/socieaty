import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/transaction_review/model/transaction_review.dart';

part 'get_all_restaurant_transaction_reviews_response.freezed.dart';
part 'get_all_restaurant_transaction_reviews_response.g.dart';

@freezed
class GetAllRestaurantTransactionReviewsResponse with _$GetAllRestaurantTransactionReviewsResponse{
  const factory GetAllRestaurantTransactionReviewsResponse({
    required int count,
    required double rating,
    required List<TransactionReview> reviews
  }) = _GetAllRestaurantTransactionReviewsResponse;

  factory GetAllRestaurantTransactionReviewsResponse.fromJson(Map<String, dynamic> json) => _$GetAllRestaurantTransactionReviewsResponseFromJson(json);
}