import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/shared/view_state.dart';

part 'live_screen_view_state.freezed.dart';

@freezed
class LiveScreenViewState with _$LiveScreenViewState {
  const factory LiveScreenViewState({
    required ViewState<bool> isDeleted,
  }) = _LiveScreenViewState;
}
