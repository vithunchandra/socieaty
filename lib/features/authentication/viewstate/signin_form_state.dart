import 'package:freezed_annotation/freezed_annotation.dart';

part 'signin_form_state.freezed.dart';
part 'signin_form_state.g.dart';

@freezed
class SigninFormState with _$SigninFormState {
  const factory SigninFormState({
    @Default(null) String? email,
    @Default(null) String? password,
  }) = _SigninFormState;

  factory SigninFormState.fromJson(Map<String, dynamic> json) => _$SigninFormStateFromJson(json);
}
