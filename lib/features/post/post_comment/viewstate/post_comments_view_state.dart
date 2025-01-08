import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/post/post_comment/model/post_comment.dart';
import 'package:socieaty/shared/view_state.dart';

part 'post_comments_view_state.freezed.dart';

@freezed
class PostCommentsViewState with _$PostCommentsViewState {
  const factory PostCommentsViewState({required ViewState<PostComment> createCommentState}) = _PostCommentsViewState;
}
