import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/admin/viewstate/post_configuration_card_view_state.dart';
import 'package:socieaty/features/post/post/repository/post_repository.dart';
import 'package:socieaty/shared/view_state.dart';

part 'post_configuration_card_view_model.g.dart';

@riverpod
class PostConfigurationCardViewModel extends _$PostConfigurationCardViewModel {
  late PostRepository _postRepository;

  @override
  PostConfigurationCardViewState build(String postId) {
    _postRepository = ref.watch(postRepositoryProvider);
    return PostConfigurationCardViewState(postId: postId, deleteResponse: IdleState());
  }

  Future<void> deletePost() async {
    state = state.copyWith(deleteResponse: LoadingState());
    final result = await _postRepository.deletePost(state.postId);
    switch (result) {
      case Success(data: final data):
        state = state.copyWith(deleteResponse: SuccessState(data: data.message));
      case Error(error: final error):
        state = state.copyWith(deleteResponse: ErrorState(message: error.message));
    }
  }
}
