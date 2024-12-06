import 'package:freezed_annotation/freezed_annotation.dart';

part 'signup_customer_form_state.freezed.dart';
part 'signup_customer_form_state.g.dart';

@freezed
class SignupCustomerFormState with _$SignupCustomerFormState {
  factory SignupCustomerFormState({
    String? name,
    String? email,
    String? phoneNumber,
    String? password,
    String? confirmPassword,
  }) = _SignupCustomerFormState;

  factory SignupCustomerFormState.fromJson(Map<String, dynamic> json) => _$SignupCustomerFormStateFromJson(json);
}
