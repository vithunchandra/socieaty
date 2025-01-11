import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/post/post/model/like_post_response.dart';
import 'package:socieaty/shared/view_state.dart';

part 'post_view_state.freezed.dart';

@freezed
class PostViewState with _$PostViewState {
  factory PostViewState({
    required String postId,
    required int comments,
    required ViewState<LikePostResponse> likeState,
  }) = _PostViewState;
}
