import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/post/post_comment/repository/response/like_post_comment_response.dart';
import 'package:socieaty/features/post/post_comment/repository/post_comment_repository.dart';
import 'package:socieaty/features/post/post_comment/viewstate/post_comment_detail_view_state.dart';
import 'package:socieaty/shared/view_state.dart';

part 'post_comment_detail_view_model.g.dart';

@riverpod
class PostCommentDetailViewModel extends _$PostCommentDetailViewModel {
  late PostCommentRepository _postCommentRepository;

  @override
  PostCommentDetailViewState build({required String postId, required String commentId}) {
    _postCommentRepository = ref.watch(postCommentRepositoryProvider);
    return PostCommentDetailViewState(
      postId: postId,
      commentId: commentId,
      likePostCommentState: IdleState(),
    );
  }

  Future<void> likePostComment(bool isLiked) async {
    final result = await _postCommentRepository.likePostComment(state.postId, state.commentId, isLiked);
    switch (result) {
      case Success<LikePostCommentResponse>(data: final data):
        state = state.copyWith(likePostCommentState: SuccessState(data: data));
      case Error(error: final error):
        state = state.copyWith(likePostCommentState: ErrorState(message: error.message));
    }
  }
}
