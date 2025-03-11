import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/transaction_review/repository/transaction_review_repository.dart';
import 'package:socieaty/features/transaction_review/viewstate/create_transaction_review_form_state.dart';
import 'package:socieaty/features/transaction_review/viewstate/restaurant_rating_screen_view_state.dart';
import 'package:socieaty/shared/view_state.dart';

part 'restaurant_rating_screen_view_model.g.dart';

@riverpod
class RestaurantRatingScreenViewModel extends _$RestaurantRatingScreenViewModel {
  late TransactionReviewRepository _transactionReviewRepository;

  @override
  RestaurantRatingScreenViewState build(String transactionId) {
    _transactionReviewRepository = ref.watch(transactionReviewRepositoryProvider);
    return RestaurantRatingScreenViewState(
      transactionId: transactionId,
      createReviewState: IdleState(),
    );
  }

  Future<void> createReview(CreateTransactionReviewFormState data) async {
    state = state.copyWith(createReviewState: LoadingState());
    final result = await _transactionReviewRepository.createTransactionReview(
      state.transactionId,
      data,
    );
    switch (result) {
      case Success(data: final data):
        state = state.copyWith(createReviewState: SuccessState(data: data.review));
      case Error(error: final error):
        state = state.copyWith(createReviewState: ErrorState(message: error.toString()));
    }
  }
}
