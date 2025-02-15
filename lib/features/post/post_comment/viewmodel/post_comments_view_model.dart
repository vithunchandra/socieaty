import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/post/post/viewmodel/post_detail_view_model.dart';
import 'package:socieaty/features/post/post_comment/model/create_post_comment_response.dart';
import 'package:socieaty/features/post/post_comment/model/get_post_comments_response.dart';
import 'package:socieaty/features/post/post_comment/model/post_comment.dart';
import 'package:socieaty/features/post/post_comment/repository/post_comment_repository.dart';
import 'package:socieaty/features/post/post_comment/viewstate/post_comments_form_state.dart';
import 'package:socieaty/shared/view_state.dart';

import '../viewstate/post_comments_view_state.dart';

part 'post_comments_view_model.g.dart';

@riverpod
Future<List<PostComment>> postComments(Ref ref, String postId) async {
  final postCommentRepository = ref.watch(postCommentRepositoryProvider);
  final result = await postCommentRepository.getPostComments(postId);
  switch (result) {
    case Success<GetPostCommentsResponse>(data: final data):
      ref.read(postDetailViewModelProvider(postId: postId).notifier).setComments(data.comments.length);
      return data.comments;
    case Error(error: final error):
      throw Exception(error.message);
  }
}

@riverpod
class PostCommentsViewModel extends _$PostCommentsViewModel {
  late PostCommentRepository _postCommentRepository;

  @override
  PostCommentsViewState build() {
    _postCommentRepository = ref.watch(postCommentRepositoryProvider);
    return PostCommentsViewState(createCommentState: IdleState());
  }

  Future<void> createPostComment(PostCommentsFormState data, String postId) async {
    state = state.copyWith(createCommentState: LoadingState());
    final result = await _postCommentRepository.createPostComment(data, postId);
    switch (result) {
      case Success<CreatePostCommentResponse>(data: final data):
        state = state.copyWith(createCommentState: SuccessState(data: data.comment));
      case Error(error: final error):
        state = state.copyWith(createCommentState: ErrorState(message: error.message));
    }
  }
}
