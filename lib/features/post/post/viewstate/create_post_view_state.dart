import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/post/post/model/post.dart';
import 'package:socieaty/shared/view_state.dart';

part 'create_post_view_state.freezed.dart';

@freezed
class CreatePostViewState with _$CreatePostViewState {
  factory CreatePostViewState({
    required ViewState<Post> createPostState,
  }) = _CreatePostViewState;
}
