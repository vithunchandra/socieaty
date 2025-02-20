import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/home/customer/viewmodel/home_screen_view_model.dart';
import 'package:socieaty/features/post/post/model/paginate_post_query.dart';
import 'package:socieaty/features/post/post/model/post.dart';
import 'package:socieaty/features/post/post/provider/paginate_posts_provider.dart';
import 'package:socieaty/features/post/post/view/post_detail_widget.dart';
import 'package:socieaty/shared/widgets/custom_error_widget.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

// Assume you have a widget that builds a single post item.
// If not, you can replace PostWidget with your own implementation.

class PostsWidget extends ConsumerStatefulWidget {
  final PaginatePostQuery? initialQuery;
  final List<Post>? initialPosts;
  const PostsWidget({super.key, this.initialQuery, this.initialPosts});

  @override
  ConsumerState<PostsWidget> createState() => _PostsWidgetState();
}

class _PostsWidgetState extends ConsumerState<PostsWidget> {
  late PaginatePostQuery _query;
  late final PagingController<int, Post> _pagingController;

  late PageController _pageController;

  void _updatePostInPagingController(Post updatedPost) {
    final itemList = _pagingController.itemList;
    if (itemList != null) {
      final index = itemList.indexWhere((post) => post.id == updatedPost.id);
      if (index != -1) {
        itemList[index] = updatedPost;
        _pagingController.itemList = List<Post>.from(itemList);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // Set up your query. If you have an initial query, use it.
    _query = widget.initialQuery ?? PaginatePostQuery(offset: 0, limit: 5);

    // Initialize the paging and page controllers.
    _pagingController = PagingController<int, Post>(firstPageKey: _query.offset);
    _pageController = PageController(initialPage: _query.offset);

    if (widget.initialPosts != null) {
      _pagingController.appendPage(widget.initialPosts!, widget.initialPosts!.length);
    }

    // Listening for new page requests from the paging controller.
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPosts(pageKey);
    });
  }

  Future<void> _fetchPosts(int pageKey) async {
    try {
      // Create a new query for the given offset (pageKey)
      final newQuery = _query.copyWith(offset: pageKey, limit: _query.limit);
      final response = await ref.read(paginatePostsProvider(newQuery).future);
      final newPosts = response.posts;
      final isLastPage = !response.pagination.hasNext;

      if (isLastPage) {
        _pagingController.appendLastPage(newPosts);
      } else {
        // Next page key based on how many items were fetched.
        final nextPageKey = pageKey + newPosts.length;
        _pagingController.appendPage(newPosts, nextPageKey);
      }
      debugPrint("HEiiiii");
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final builderDelegate = PagedChildBuilderDelegate<Post>(
      itemBuilder: (context, item, index) {
        return PostDetailWidget(
          post: item,
          userId: ref.watch(authLocalRepositoryProvider).getUserData()!.id,
          onUpdate: (post) {
            _updatePostInPagingController(post);
          },
        );
      },
      firstPageProgressIndicatorBuilder: (_) => LoadingIndicatorWidget(),
      newPageProgressIndicatorBuilder: (_) => LoadingIndicatorWidget(),
      firstPageErrorIndicatorBuilder: (context) => CustomErrorWidget(
        error: _pagingController.error,
        title: 'Posts',
        onPressed: _pagingController.refresh,
      ),
      newPageErrorIndicatorBuilder: (context) => CustomErrorWidget(
        error: _pagingController.error,
        title: 'Posts',
        onPressed: _pagingController.retryLastFailedRequest,
      ),
      noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('No posts found')),
    );

    return PagedPageView(
      pageController: _pageController,
      pagingController: _pagingController,
      scrollDirection: Axis.vertical,
      onPageChanged: (index) {
        ref
            .read(homeScreenViewModelProvider.notifier)
            .setCurrentPostId(_pagingController.itemList?[index].id ?? '');
      },
      builderDelegate: builderDelegate,
    );
  }
}
