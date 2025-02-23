import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/post/post/repository/response/create_post_response.dart';
import 'package:socieaty/features/post/post/repository/post_repository.dart';
import 'package:socieaty/features/post/post/viewstate/create_post_form_state.dart';
import 'package:socieaty/features/post/post/viewstate/create_post_view_state.dart';
import 'package:socieaty/shared/view_state.dart';

part 'create_post_view_model.g.dart';

@riverpod
class CreatePostViewModel extends _$CreatePostViewModel {
  late PostRepository _postRepository;
  @override
  CreatePostViewState build() {
    _postRepository = ref.watch(postRepositoryProvider);
    return CreatePostViewState(createPostState: IdleState());
  }

  Future<void> createPost(CreatePostFormState data, List<File> medias) async {
    state = state.copyWith(createPostState: LoadingState());
    final result = await _postRepository.createPost(data, medias);
    switch (result) {
      case Success<CreatePostResponse>(data: final data):
        state = state.copyWith(createPostState: SuccessState(data: data.post));
      case Error(error: final error):
        state = state.copyWith(createPostState: ErrorState(message: error.message));
    }
  }
}
