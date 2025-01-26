import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/livestream/repository/livestream_repository.dart';
import 'package:socieaty/features/livestream/viewstate/live_screen_view_state.dart';
import 'package:socieaty/shared/view_state.dart';

part 'live_screen_view_model.g.dart';

@Riverpod(keepAlive: true)
class LiveScreenViewModel extends _$LiveScreenViewModel {
  late LivestreamRepository _livestreamRepository;

  @override
  LiveScreenViewState build() {
    _livestreamRepository = ref.watch(livestreamRepositoryProvider);
    return LiveScreenViewState(isDeleted: IdleState());
  }

  Future<void> deleteLivestreamRoom(String roomName) async {
    state = state.copyWith(isDeleted: LoadingState());
    await Future.delayed(const Duration(seconds: 1));
    final result = await _livestreamRepository.deleteLivestreamRoom(roomName);
    switch (result) {
      case Success(data: final data):
        state = state.copyWith(isDeleted: SuccessState(data: data.isDeleted));
      case Error(message: final message):
        state = state.copyWith(isDeleted: ErrorState(message: message));
    }
  }
}
