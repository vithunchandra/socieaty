import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/post/post/model/like_post_response.dart';
import 'package:socieaty/shared/view_state.dart';

part 'post_detail_view_state.freezed.dart';

@freezed
class PostDetailViewState with _$PostDetailViewState {
  factory PostDetailViewState({
    required String postId,
    required int comments,
    required ViewState<LikePostResponse> likeState,
  }) = _PostDetailViewState;
}
