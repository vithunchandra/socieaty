import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/post/post/repository/post_repository.dart';
import 'package:socieaty/features/post/post/repository/request/update_post_request.dart';
import 'package:socieaty/features/post/post/repository/response/update_post_response.dart';
import 'package:socieaty/features/post/post/viewstate/update_post_view_state.dart';
import 'package:socieaty/shared/view_state.dart';

part 'update_post_view_model.g.dart';

@riverpod
class UpdatePostViewModel extends _$UpdatePostViewModel {
  late PostRepository postRepository;

  @override
  UpdatePostViewState build(String postId) {
    postRepository = ref.watch(postRepositoryProvider);
    return UpdatePostViewState(postId: postId, updatedPostState: IdleState());
  }

  Future<void> updatePost(UpdatePostRequest data, List<File> medias) async {
    state = state.copyWith(updatedPostState: LoadingState());
    final result = await postRepository.updatePost(postId, data, medias);
    switch (result) {
      case Success<UpdatePostResponse>(data: final data):
        state = state.copyWith(updatedPostState: SuccessState(data: data.post));
      case Error(error: final error):
        state = state.copyWith(updatedPostState: ErrorState(message: error.message));
    }
  }
}
