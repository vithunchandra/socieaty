import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';
import 'package:socieaty/shared/view_state.dart';

part 'landing_viewstate.freezed.dart';

@freezed
class LandingViewState with _$LandingViewState {
  factory LandingViewState({required ViewState<SocieatyUser> sessionState}) = _LandingViewState;
}
