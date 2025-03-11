import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/customer/model/socieaty_customer.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';

part 'transaction_review.freezed.dart';
part 'transaction_review.g.dart';

@freezed
class TransactionReview with _$TransactionReview {
  const factory TransactionReview({
    required String id,
    required String transactionId,
    required int rating,
    required String review,
    @SocieatyCustomerConverter()
    required SocieatyCustomer reviewer,
    @SocieatyRestaurantConverter()
    required SocieatyRestaurant restaurant,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TransactionReview;

  factory TransactionReview.fromJson(Map<String, dynamic> json) => _$TransactionReviewFromJson(json);
}