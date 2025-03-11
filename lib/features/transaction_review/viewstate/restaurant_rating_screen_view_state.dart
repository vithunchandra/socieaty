import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/transaction_review/model/transaction_review.dart';
import 'package:socieaty/shared/view_state.dart';

part 'restaurant_rating_screen_view_state.freezed.dart';

@freezed
class RestaurantRatingScreenViewState with _$RestaurantRatingScreenViewState {
  const factory RestaurantRatingScreenViewState({
    required String transactionId,
    required ViewState<TransactionReview> createReviewState,
  }) = _RestaurantRatingScreenViewState;
}
