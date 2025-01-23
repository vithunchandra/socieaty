import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/livestream/model/live_room.dart';
import 'package:socieaty/shared/view_state.dart';

part 'livestream_home_view_state.freezed.dart';

@freezed
class LivestreamHomeViewState with _$LivestreamHomeViewState {
  const factory LivestreamHomeViewState({
    required ViewState<List<LiveRoom>> rooms,
  }) = _LivestreamHomeViewState;
}
