import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/app_theme.dart';
import 'package:socieaty/core/theme/theme.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/post/post/model/paginate_post_query.dart';
import 'package:socieaty/features/post/post/model/post.dart';
import 'package:socieaty/features/post/post/provider/paginate_posts_provider.dart';
import 'package:socieaty/features/post/post/view/post_screen.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';
import 'package:socieaty/shared/widgets/image_error_widget.dart';
import 'package:socieaty/shared/widgets/image_loading_widget.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PostCard extends StatefulWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.post.medias.first.type == "image"
        ? widget.post.medias.first.url
        : widget.post.medias.first.videoThumbnailUrl ?? "";
    final mediaWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      progressIndicatorBuilder: (context, url, downloadProgress) =>
          imageLoadingWidget(context, url, downloadProgress),
      errorWidget: (context, url, error) => imageErrorWidget(context, error, null),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      margin: EdgeInsets.zero,
      child: mediaWidget,
    );
  }
}

/// A widget that displays posts in a paginated masonry view using infinite_scroll_pagination.
class OutletPostWidget extends ConsumerStatefulWidget {
  final SocieatyUser restaurant;

  const OutletPostWidget(this.restaurant, {super.key});

  @override
  ConsumerState<OutletPostWidget> createState() => _OutletPostWidgetState();
}

class _OutletPostWidgetState extends ConsumerState<OutletPostWidget> {
  static const _pageSize = 10;
  final PagingController<int, Post> _pagingController = PagingController(firstPageKey: 0);

  // Flag to track disposal state.
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    // Listen for new page requests and ensure disposal state is checked.
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  /// This method uses your Riverpod provider to fetch a page of posts.
  Future<void> _fetchPage(int pageKey) async {
    // Check if widget is still mounted and not disposed
    if (mounted && !_isDisposed) {
      try {
        final response = await ref.read(
          paginatePostsProvider(
            PaginatePostQuery(
              offset: pageKey,
              limit: _pageSize,
              authorId: widget.restaurant.id,
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
          final nextPageKey = response.pagination.nextOffset;
          if (!_isDisposed) {
            _pagingController.appendPage(newItems, nextPageKey);
          }
        }
      } catch (error) {
        if (!_isDisposed) {
          _pagingController.error = error;
          showSnackbar(context, error.toString(), isError: true);
        }
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the infinite pagination grid in SliverPadding to match any styling requirements.
    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      sliver: PagedSliverGrid(
        pagingController: _pagingController,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
        ),
        builderDelegate: PagedChildBuilderDelegate<Post>(
          itemBuilder: (context, post, index) {
            return GestureDetector(
              onTap: () {
                ref.read(appThemeProvider.notifier).setTheme(SocieatyAppTheme.darkTheme);
                context.push(
                  '/posts',
                  extra: PostScreenArgs(
                    previousTheme: SocieatyAppTheme.lightTheme,
                    paginatePostQuery:
                        PaginatePostQuery(authorId: widget.restaurant.id, offset: index),
                    posts: _pagingController.itemList,
                  ),
                );
              },
              child: PostCard(post: post),
            );
          },
          firstPageProgressIndicatorBuilder: (context) => LoadingIndicatorWidget(),
          newPageProgressIndicatorBuilder: (context) => LoadingIndicatorWidget(),
          noItemsFoundIndicatorBuilder: (context) => const Center(child: Text("No posts found")),
        ),
      ),
    );
  }
}
