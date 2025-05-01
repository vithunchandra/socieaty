import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/shared/view_state.dart';

part 'verify_restaurant_view_state.freezed.dart';

@freezed
class VerifyRestaurantViewState with _$VerifyRestaurantViewState {
  const factory VerifyRestaurantViewState({
    required String restaurantId,
    required ViewState<String> rejectVerificationState,
    required ViewState<String> verifyRestaurantState,
  }) = _VerifyRestaurantViewState;
}

