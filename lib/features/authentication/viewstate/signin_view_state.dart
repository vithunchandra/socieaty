import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';

import '../../../shared/view_state.dart';

part 'signin_view_state.freezed.dart';

@freezed
class SigninViewState with _$SigninViewState {
  factory SigninViewState({
    required ViewState<SocieatyUser> signinState,
  }) = _SigninViewState;
}
