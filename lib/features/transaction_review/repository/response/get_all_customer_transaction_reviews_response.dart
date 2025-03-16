
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/transaction_review/model/transaction_review.dart';

part 'get_all_customer_transaction_reviews_response.freezed.dart';
part 'get_all_customer_transaction_reviews_response.g.dart';

@freezed
class GetAllCustomerTransactionReviewsResponse with _$GetAllCustomerTransactionReviewsResponse{
  const factory GetAllCustomerTransactionReviewsResponse({
    required List<TransactionReview> reviews
  }) = _GetAllCustomerTransactionReviewsResponse;

  factory GetAllCustomerTransactionReviewsResponse.fromJson(Map<String, dynamic> json) => _$GetAllCustomerTransactionReviewsResponseFromJson(json);
}
