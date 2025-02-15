import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/features/post/post/model/paginate_post_query.dart';
import 'package:socieaty/features/post/post/provider/paginate_posts_provider.dart';
import 'package:socieaty/features/post/post/viewstate/posts_view_state.dart';
import 'package:socieaty/shared/view_state.dart';

part 'posts_widget_view_model.g.dart';

@riverpod
class PostsWidgetViewModel extends _$PostsWidgetViewModel {
  @override
  PostsViewState build() {
    final posts = ref.watch(paginatePostsProvider(PaginatePostQuery(offset: 0, limit: 5)));
    return PostsViewState(posts: IdleState());
  }
}
