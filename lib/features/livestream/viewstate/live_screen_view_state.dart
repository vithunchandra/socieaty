import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:livekit_client/livekit_client.dart';

part 'live_screen_view_state.freezed.dart';

@freezed
class LiveScreenViewState with _$LiveScreenViewState {
  const factory LiveScreenViewState({
    @Default(null) Room? room,
  }) = _LiveScreenViewState;
}
