import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/transaction_review/model/transaction_review.dart';

part 'create_transaction_review_response.freezed.dart';
part 'create_transaction_review_response.g.dart';

@freezed
class CreateTransactionReviewResponse with _$CreateTransactionReviewResponse {
  const factory CreateTransactionReviewResponse({
    required TransactionReview review,
  }) = _CreateTransactionReviewResponse;

  factory CreateTransactionReviewResponse.fromJson(Map<String, dynamic> json) => _$CreateTransactionReviewResponseFromJson(json);
}
