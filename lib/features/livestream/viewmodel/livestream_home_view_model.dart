import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/features/livestream/repository/livestream_repository.dart';
import 'package:socieaty/features/livestream/viewstate/livestream_home_view_state.dart';
import 'package:socieaty/shared/view_state.dart';

part 'livestream_home_view_model.g.dart';

@riverpod
class LivestreamHomeViewModel extends _$LivestreamHomeViewModel {
  @override
  LivestreamHomeViewState build() {
    return LivestreamHomeViewState(rooms: IdleState());
  }
}
