import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_transaction_review_form_state.freezed.dart';
part 'create_transaction_review_form_state.g.dart';

@freezed
class CreateTransactionReviewFormState with _$CreateTransactionReviewFormState {
  const factory CreateTransactionReviewFormState({
    @Default(0) int rating,
    @Default('') String review,
  }) = _CreateTransactionReviewFormState;

  factory CreateTransactionReviewFormState.fromJson(Map<String, dynamic> json) =>
      _$CreateTransactionReviewFormStateFromJson(json);
}
