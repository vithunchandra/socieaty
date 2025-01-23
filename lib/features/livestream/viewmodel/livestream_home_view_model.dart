import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/features/livestream/repository/livestream_repository.dart';
import 'package:socieaty/features/livestream/viewstate/livestream_home_view_state.dart';
import 'package:socieaty/shared/view_state.dart';

part 'livestream_home_view_model.g.dart';

@riverpod
class LivestreamHomeViewModel extends _$LivestreamHomeViewModel {
  late LivestreamRepository _livestreamRepository;
  @override
  LivestreamHomeViewState build() {
    _livestreamRepository = ref.watch(livestreamRepositoryProvider);
    return LivestreamHomeViewState(rooms: IdleState());
  }
}
