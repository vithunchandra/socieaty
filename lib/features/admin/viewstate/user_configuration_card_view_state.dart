import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';
import 'package:socieaty/shared/view_state.dart';

part 'user_configuration_card_view_state.freezed.dart';

@freezed
class UserConfigurationCardViewState with _$UserConfigurationCardViewState {
  const factory UserConfigurationCardViewState({
    required String userId,
    required ViewState<SocieatyUser> userData,
  }) = _UserConfigurationCardViewState;
}
