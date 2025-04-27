import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/admin/viewstate/livestream_configuration_card_view_state.dart';
import 'package:socieaty/features/livestream/repository/livestream_repository.dart';
import 'package:socieaty/shared/view_state.dart';

part 'livestream_configuration_card_view_model.g.dart';

@riverpod
class LivestreamConfigurationCardViewModel extends _$LivestreamConfigurationCardViewModel {
  late LivestreamRepository livestreamRepository;

  @override
  LivestreamConfigurationCardViewState build(String roomName) {
    livestreamRepository = ref.watch(livestreamRepositoryProvider);
    return LivestreamConfigurationCardViewState(
      roomName: roomName,
      isDeletedState: IdleState(),
    );
  }

  Future<void> deleteLivestreamRoom(String roomName) async {
    state = state.copyWith(isDeletedState: LoadingState());
    final result = await livestreamRepository.deleteLivestreamRoom(roomName);
    switch (result) {
      case Success(data: final data):
        state = state.copyWith(isDeletedState: SuccessState(data: data.isDeleted));
      case Error(error: final error):
        state = state.copyWith(isDeletedState: ErrorState(message: error.message));
    }
  }
}
