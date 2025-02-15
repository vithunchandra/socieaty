import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/post/post/model/post.dart';
import 'package:socieaty/shared/view_state.dart';

part 'posts_view_state.freezed.dart';

@freezed
class PostsViewState with _$PostsViewState {
  const factory PostsViewState({
    required ViewState<List<Post>> posts,
  }) = _PostsViewState;
}
