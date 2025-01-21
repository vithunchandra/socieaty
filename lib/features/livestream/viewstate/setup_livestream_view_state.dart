import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/shared/view_state.dart';

part 'setup_livestream_view_state.freezed.dart';

@freezed
class SetupLivestreamViewState with _$SetupLivestreamViewState {
  const factory SetupLivestreamViewState({
    required ViewState<String> accessTokenState,
  }) = _SetupLivestreamViewState;
}
