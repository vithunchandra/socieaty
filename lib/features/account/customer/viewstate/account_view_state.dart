import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/shared/view_state.dart';

part 'account_view_state.freezed.dart';

@freezed
class AccountViewState with _$AccountViewState {
  factory AccountViewState({
    required ViewState<bool> isSignedOut,
  }) = _AccountViewState;
}
