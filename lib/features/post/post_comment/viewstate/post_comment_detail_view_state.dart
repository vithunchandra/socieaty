import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/post/post_comment/repository/response/delete_post_comment_response.dart';
import 'package:socieaty/features/post/post_comment/repository/response/like_post_comment_response.dart';
import 'package:socieaty/shared/view_state.dart';

part 'post_comment_detail_view_state.freezed.dart';

@freezed
class PostCommentDetailViewState with _$PostCommentDetailViewState {
  factory PostCommentDetailViewState({
    required String postId,
    required String commentId,
    required ViewState<LikePostCommentResponse> likePostCommentState,
    required ViewState<DeletePostCommentResponse> deletePostCommentState,
  }) = _PostCommentDetailViewState;
}
