import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/livestream/repository/livestream_repository.dart';
import 'package:socieaty/features/livestream/viewstate/setup_livestream_form_state.dart';
import 'package:socieaty/features/livestream/viewstate/setup_livestream_view_state.dart';
import 'package:socieaty/shared/view_state.dart';

part 'setup_livestream_view_model.g.dart';

@riverpod
class SetupLivestreamViewModel extends _$SetupLivestreamViewModel {
  late LivestreamRepository _livestreamRepository;

  @override
  SetupLivestreamViewState build() {
    _livestreamRepository = ref.watch(livestreamRepositoryProvider);
    return SetupLivestreamViewState(accessTokenState: IdleState());
  }

  Future<void> startLivestream(SetupLivestreamFormState data) async {
    final result = await _livestreamRepository.startLivestream(data);
    switch (result) {
      case Success(data: final data):
        state = state.copyWith(accessTokenState: SuccessState(data: data.accessToken));
      case Error(error: final error):
        state = state.copyWith(accessTokenState: ErrorState(message: error.message));
    }
  }
}
