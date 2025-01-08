import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/post/post_comment/model/create_post_comment_response.dart';
import 'package:socieaty/features/post/post_comment/repository/post_comment_repository.dart';
import 'package:socieaty/features/post/post_comment/viewstate/post_comments_form_state.dart';
import 'package:socieaty/shared/view_state.dart';

import '../viewstate/post_comments_view_state.dart';

part 'post_comments_view_model.g.dart';

@riverpod
class PostCommentsViewModel extends _$PostCommentsViewModel {
  late final PostCommentRepository _postCommentRepository;

  @override
  PostCommentsViewState build() {
    _postCommentRepository = ref.watch(postCommentRepositoryProvider);
    return PostCommentsViewState(createCommentState: IdleState());
  }

  Future<void> createComment(PostCommentsFormState data) async {
    state = state.copyWith(createCommentState: LoadingState());
    final result = await _postCommentRepository.createPostComment(data);
    switch (result) {
      case Success<CreatePostCommentResponse>(data: final data):
        state = state.copyWith(createCommentState: SuccessState(data: data.comment));
      case Error(message: final message):
        state = state.copyWith(createCommentState: ErrorState(message: message));
    }
  }
}
