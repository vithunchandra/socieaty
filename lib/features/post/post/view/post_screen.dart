import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:socieaty/features/post/post/model/post.dart';
import 'package:socieaty/features/post/post/repository/request/paginate_post_query.dart';
import 'package:socieaty/features/post/post/view/posts_widget.dart';
import 'package:socieaty/shared/widgets/scaffold_with_custom_theme.dart';

class PostScreenArgs {
  final ThemeData previousTheme;
  final PaginatePostQuery paginatePostQuery;
  final PagingController<int, Post>? pagingController;
  // final List<Post>? posts;
  final int? initialPostIndex;

  PostScreenArgs({required this.previousTheme, required this.paginatePostQuery, this.pagingController, this.initialPostIndex});
}

class PostScreen extends StatelessWidget {
  final PostScreenArgs args;
  const PostScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithCustomTheme(
      previousTheme: args.previousTheme,
      body: PostsWidget(
        initialQuery: args.paginatePostQuery,
        // initialPosts: args.posts,
        initialPostIndex: args.initialPostIndex,
        pagingController: args.pagingController,
      ),
    );
  }
}
