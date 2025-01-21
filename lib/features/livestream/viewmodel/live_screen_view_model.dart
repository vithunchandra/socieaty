import 'package:livekit_client/livekit_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/features/livestream/viewstate/live_screen_view_state.dart';

part 'live_screen_view_model.g.dart';

@Riverpod(keepAlive: true)
class LiveScreenViewModel extends _$LiveScreenViewModel {
  @override
  LiveScreenViewState build() {
    return LiveScreenViewState(room: null);
  }

  void setRoom(Room room) {
    state = state.copyWith(room: room);
  }

  Room? getRoom() {
    return state.room;
  }
}
