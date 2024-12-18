import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';
import 'package:socieaty/shared/view_state.dart';

part 'signup_customer_view_state.freezed.dart';

@freezed
class SignupCustomerViewState with _$SignupCustomerViewState {
  factory SignupCustomerViewState({
    required ViewState<SocieatyUser> signupState,
  }) = _SignupCustomerViewState;
}
