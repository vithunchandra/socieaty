import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/features/post/post/model/post.dart';

part 'posts_widget_view_model.g.dart';

@riverpod
class PostsWidgetViewModel extends _$PostsWidgetViewModel {
  @override
  List<Post> build(String? authorId) {
    return [];
  }

  void addPosts(List<Post> posts) {
    state = [...state, ...posts];
  }

  void setPosts(List<Post> posts) {
    state = posts;
  }

  void updatePosts(Post post, int index) {
    final newState = [...state];
    newState[index] = post;
    state = newState;
  }

  void removePost(int index) {
    final newState = [...state];
    newState.removeAt(index);
    state = newState;
  }

  void clearPosts() {
    state = [];
  }
}
