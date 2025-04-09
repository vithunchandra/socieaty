import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/post/post/model/post.dart';
import 'package:socieaty/shared/view_state.dart';

part 'update_post_view_state.freezed.dart';

@freezed
class UpdatePostViewState with _$UpdatePostViewState {
  const factory UpdatePostViewState({
    required String postId,
    required ViewState<Post> updatedPostState,
  }) = _UpdatePostViewState;
}