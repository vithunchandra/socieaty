import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/home/customer/viewmodel/home_screen_view_model.dart';
import 'package:socieaty/features/post/post/model/post.dart';
import 'package:socieaty/features/post/post/provider/paginate_posts_provider.dart';
import 'package:socieaty/features/post/post/repository/request/paginate_post_query.dart';
import 'package:socieaty/features/post/post/view/post_detail_widget.dart';
import 'package:socieaty/shared/models/pagination_query.dart';
import 'package:socieaty/shared/widgets/custom_error_widget.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class PostsWidget extends ConsumerStatefulWidget {
  final PaginatePostQuery? initialQuery;
  final int? initialPostIndex;
  // final List<Post>? initialPosts;
  final PagingController<int, Post>? pagingController;
  const PostsWidget({super.key, this.initialQuery, this.initialPostIndex, this.pagingController});

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
    setState(() {});
  }

  void _deletePostInPagingController(Post deletedPost) {
    final itemList = _pagingController.itemList;
    if (itemList != null) {
      itemList.removeWhere((post) => post.id == deletedPost.id);
      _pagingController.itemList = List<Post>.from(itemList);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _query = widget.initialQuery ??
        PaginatePostQuery(paginationQuery: PaginationQuery(page: 0, pageSize: 5));

    // _pagingController = PagingController<int, Post>(firstPageKey: _query.paginationQuery.page);

    if (widget.initialPostIndex != null) {
      _pageController = PageController(initialPage: widget.initialPostIndex!);
    } else {
      _pageController = PageController();
    }

    // if (widget.initialPosts != null) {
    //   _pagingController.appendPage(widget.initialPosts!, widget.initialPosts!.length);
    // }

    if (widget.pagingController != null) {
      _pagingController = widget.pagingController!;
    } else {
      _pagingController = PagingController<int, Post>(firstPageKey: _query.paginationQuery.page);
      _pagingController.addPageRequestListener((pageKey) {
        _fetchPosts(pageKey);
      });
    }
  }

  Future<void> _fetchPosts(int pageKey) async {
    try {
      final newQuery = _query.copyWith(
          paginationQuery:
              PaginationQuery(page: pageKey, pageSize: _query.paginationQuery.pageSize));
      final response = await ref.read(paginatePostsProvider(newQuery).future);
      final newPosts = response.posts;
      final isLastPage = !response.pagination.hasNext;
      debugPrint('isLastPage: $isLastPage');

      if (isLastPage) {
        _pagingController.appendLastPage(newPosts);
      } else {
        final nextPageKey = response.pagination.nextPage;
        _pagingController.appendPage(newPosts, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    if (widget.pagingController == null) {
      _pagingController.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final builderDelegate = PagedChildBuilderDelegate<Post>(
      itemBuilder: (context, item, index) {
        return PostDetailWidget(
          key: Key(item.id),
          args: PostDetailWidgetArgs(
            post: item,
            userId: ref.watch(authLocalRepositoryProvider).getUserData()!.id,
            onUpdate: (post) {
              _updatePostInPagingController(post);
            },
            onDelete: (post) {
              _deletePostInPagingController(post);
            },
          ),
        );
      },
      firstPageProgressIndicatorBuilder: (_) => const LoadingIndicatorWidget(size: 36),
      newPageProgressIndicatorBuilder: (_) => const LoadingIndicatorWidget(size: 36),
      firstPageErrorIndicatorBuilder: (context) => CustomErrorWidget(
        error: _pagingController.error.toString(),
        title: 'Posts',
        onPressed: _pagingController.refresh,
      ),
      newPageErrorIndicatorBuilder: (context) => CustomErrorWidget(
        error: _pagingController.error,
        title: 'Posts',
        onPressed: _pagingController.retryLastFailedRequest,
      ),
      noItemsFoundIndicatorBuilder: (context) => const Center(child: Text('Tidak ada postingan yang ditemukan')),
    );

    return PagedPageView(
      pageController: _pageController,
      pagingController: _pagingController,
      scrollDirection: Axis.vertical,
      onPageChanged: (index) {
        if (_pagingController.itemList != null && index < _pagingController.itemList!.length) {
          ref
              .read(homeScreenViewModelProvider.notifier)
              .setCurrentPostId(_pagingController.itemList![index].id);
        }
      },
      builderDelegate: builderDelegate,
    );
  }
}
