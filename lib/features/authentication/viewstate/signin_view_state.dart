import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/view_state.dart';

part 'signin_view_state.freezed.dart';

@freezed
class SigninViewState with _$SigninViewState {
  factory SigninViewState({
    required ViewState<String> signinState,
  }) = _SigninViewState;
}
