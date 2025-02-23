import 'package:flutter/material.dart';
import 'package:socieaty/features/post/post/repository/response/paginate_post_query.dart';
import 'package:socieaty/features/post/post/model/post.dart';
import 'package:socieaty/features/post/post/view/posts_widget.dart';
import 'package:socieaty/shared/widgets/scaffold_with_custom_theme.dart';

class PostScreenArgs {
  final ThemeData previousTheme;
  final PaginatePostQuery paginatePostQuery;
  final List<Post>? posts;

  PostScreenArgs({required this.previousTheme, required this.paginatePostQuery, this.posts});

  // Add a toJson method to allow serialization by GoRouter.
  // Note: ThemeData is not trivially serializable so we omit it.
  Map<String, dynamic> toJson() {
    return {
      // 'previousTheme': previousTheme.toString(), // Omitted or adjust as needed.
      'paginatePostQuery':
          paginatePostQuery.toJson(), // Ensure PaginatePostQuery implements toJson.
      'posts': posts?.map((post) => post.toJson()).toList(), // Ensure Post implements toJson.
    };
  }
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
        initialPosts: args.posts,
      ),
    );
  }
}
