import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:socieaty/app_theme_provider.dart';
import 'package:socieaty/core/theme/theme.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/post/post/repository/request/paginate_post_query.dart';
import 'package:socieaty/features/post/post/model/post.dart';
import 'package:socieaty/features/post/post/provider/paginate_posts_provider.dart';
import 'package:socieaty/features/post/post/view/post_card_widget.dart';
import 'package:socieaty/features/post/post/view/post_screen.dart';
import 'package:socieaty/features/post/post/viewmodel/posts_widget_view_model.dart';
import 'package:socieaty/shared/models/pagination_query.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class PostGridWidget extends ConsumerStatefulWidget {
  final String authorId;
  const PostGridWidget({super.key, required this.authorId});

  @override
  ConsumerState<PostGridWidget> createState() => _PostGridWidgetState();
}

class _PostGridWidgetState extends ConsumerState<PostGridWidget> {
  static const _pageSize = 8;
  final PagingController<int, Post> _pagingController = PagingController(firstPageKey: 0);

  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    if (mounted && !_isDisposed) {
      try {
        final response = await ref.read(
          paginatePostsProvider(
            PaginatePostQuery(
              paginationQuery: PaginationQuery(
                page: pageKey,
                pageSize: _pageSize,
              ),
              authorId: widget.authorId,
            ),
          ).future,
        );

        final newItems = response.posts;
        final isLastPage = !response.pagination.hasNext;
        if (isLastPage) {
          if (!_isDisposed) {
            _pagingController.appendLastPage(newItems);
          }
        } else {
          final nextPageKey = response.pagination.nextPage;
          if (!_isDisposed) {
            _pagingController.appendPage(newItems, nextPageKey);
          }
        }
      } catch (error) {
        if (!_isDisposed) {
          _pagingController.error = error;
          showSnackbar(null, error.toString(), state: SnackbarState.error);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PagedGridView(
      pagingController: _pagingController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
      ),
      builderDelegate: PagedChildBuilderDelegate<Post>(
        itemBuilder: (context, post, index) {
          return GestureDetector(
            onTap: () {
              ref.read(appThemeProvider.notifier).setTheme(SocieatyAppTheme.darkTheme);
              ref
                  .read(postsWidgetViewModelProvider(widget.authorId).notifier)
                  .addPosts(_pagingController.itemList ?? []);
              context.push(
                '/posts',
                extra: PostScreenArgs(
                  previousTheme: SocieatyAppTheme.lightTheme,
                  paginatePostQuery: PaginatePostQuery(
                    authorId: widget.authorId,
                    paginationQuery: PaginationQuery(
                      page: _pagingController.nextPageKey ?? 0,
                      pageSize: _pageSize,
                    ),
                  ),
                  // posts: _pagingController.itemList,
                  pagingController: _pagingController,
                  initialPostIndex: index,
                ),
              );
            },
            child: PostCardWidget(post: post),
          );
        },
        firstPageProgressIndicatorBuilder: (context) => const LoadingIndicatorWidget(size: 32),
        newPageProgressIndicatorBuilder: (context) => const LoadingIndicatorWidget(size: 32),
        noItemsFoundIndicatorBuilder: (context) => const Center(child: Text("Tidak ada postingan yang ditemukan")),
      ),
    );
  }
}
