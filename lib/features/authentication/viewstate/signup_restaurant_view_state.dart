import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';
import 'package:socieaty/shared/view_state.dart';

part 'signup_restaurant_view_state.freezed.dart';

@freezed
class SignupRestaurantViewState with _$SignupRestaurantViewState {
  const factory SignupRestaurantViewState({
    required ViewState<SocieatyUser> signupRestaurantState,
  }) = _SignupRestaurantViewState;
}
