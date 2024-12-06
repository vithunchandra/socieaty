import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/authentication/model/signup_customer_response.dart';
import 'package:socieaty/shared/view_state.dart';

part 'signup_customer_view_state.freezed.dart';

@freezed
class SignupCustomerViewState with _$SignupCustomerViewState {
  factory SignupCustomerViewState({
    required ViewState<SignupCustomerResponse> signupState,
  }) = _SignupCustomerViewState;
}
