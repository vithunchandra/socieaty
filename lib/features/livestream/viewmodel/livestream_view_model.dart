import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/livestream/repository/livestream_repository.dart';
import 'package:socieaty/features/livestream/viewstate/livestream_view_state.dart';
import 'package:socieaty/shared/view_state.dart';

part 'livestream_view_model.g.dart';

@riverpod
class LivestreamViewModel extends _$LivestreamViewModel {
  late LivestreamRepository _livestreamRepository;

  @override
  LivestreamViewState build({required String roomName}) {
    _livestreamRepository = ref.watch(livestreamRepositoryProvider);
    return LivestreamViewState(
      roomName: roomName,
      comment: IdleState(),
      likes: IdleState(),
    );
  }

  Future<void> sendComment(String comment) async {
    state = state.copyWith(comment: LoadingState());
    final result = await _livestreamRepository.sendLivestreamComment(state.roomName, comment);
    switch (result) {
      case Success(data: final data):
        state = state.copyWith(comment: SuccessState(data: data.comment));
      case Error(message: final message):
        state = state.copyWith(comment: ErrorState(message: message));
    }
  }

  Future<void> sendLike(bool isLiked) async {
    state = state.copyWith(likes: LoadingState());
    final result = await _livestreamRepository.sendLivestreamLike(state.roomName, isLiked);
    switch (result) {
      case Success(data: final data):
        state = state.copyWith(likes: SuccessState(data: data));
      case Error(message: final message):
        state = state.copyWith(likes: ErrorState(message: message));
    }
  }
}
