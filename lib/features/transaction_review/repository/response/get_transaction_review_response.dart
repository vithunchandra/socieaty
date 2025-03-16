import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/transaction_review/model/transaction_review.dart';

part 'get_transaction_review_response.freezed.dart';
part 'get_transaction_review_response.g.dart';

@freezed
class GetTransactionReviewResponse with _$GetTransactionReviewResponse{
  const factory GetTransactionReviewResponse({
    required TransactionReview review
  }) = _GetTransactionReviewResponse;

  factory GetTransactionReviewResponse.fromJson(Map<String, dynamic> json) => _$GetTransactionReviewResponseFromJson(json);
}
