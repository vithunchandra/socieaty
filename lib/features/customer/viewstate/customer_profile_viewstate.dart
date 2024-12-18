import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';
import 'package:socieaty/shared/view_state.dart';

part 'customer_profile_viewstate.freezed.dart';

@freezed
class CustomerProfileViewState with _$CustomerProfileViewState {
  factory CustomerProfileViewState({
    required ViewState<SocieatyUser> userDataState,
  }) = _CustomerProfileViewstate;
}
