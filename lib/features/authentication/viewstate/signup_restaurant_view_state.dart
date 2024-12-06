import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/authentication/model/signup_restaurant_response.dart';

part 'signup_restaurant_view_state.freezed.dart';
part 'signup_restaurant_view_state.g.dart';

@freezed
class SignupRestaurantViewState with _$SignupRestaurantViewState {
  const factory SignupRestaurantViewState({
    required bool isSignupLoading,
    required SignupRestaurantResponse? data,
    required bool isSignupError,
    required String signupErrorMessage,
  }) = _SignupRestaurantViewState;

  factory SignupRestaurantViewState.fromJson(Map<String, Object?> json) => _$SignupRestaurantViewStateFromJson(json);
}
