import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:socieaty/core/enums/user_role.enum.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/post/post/model/post.dart';
import 'package:socieaty/features/post/post/provider/paginate_posts_provider.dart';
import 'package:socieaty/features/post/post/repository/request/paginate_post_query.dart';
import 'package:socieaty/shared/models/pagination_query.dart';
import 'package:socieaty/shared/widgets/custom_error_widget.dart';
import 'package:socieaty/shared/widgets/custom_loading_widget.dart';
import 'package:socieaty/features/admin/view/widgets/post_card_widget.dart';

class ConfigureContentScreen extends ConsumerStatefulWidget {
  const ConfigureContentScreen({super.key});

  @override
  ConsumerState<ConfigureContentScreen> createState() => _ConfigureContentScreenState();
}

class _ConfigureContentScreenState extends ConsumerState<ConfigureContentScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PagingController<int, Post> _pagingController = PagingController(firstPageKey: 0);
  final int _pageSize = 10;
  bool _isDisposed = false;

  UserRole? _selectedRole;
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPosts(pageKey);
    });
  }

  Future<void> _fetchPosts(int pageKey) async {
    if (!mounted || _isDisposed) return;

    try {
      final query = PaginatePostQuery(
        paginationQuery: PaginationQuery(page: pageKey, pageSize: _pageSize),
        searchQuery: _searchQuery,
        userRole: _selectedRole,
      );

      debugPrint("query: $query");

      final response = await ref.read(paginatePostsProvider(query).future);
      final posts = response.posts;
      final pagination = response.pagination;

      final isLastPage = !pagination.hasNext;

      if (isLastPage) {
        _pagingController.appendLastPage(posts);
      } else {
        final nextPageKey = pagination.nextPage;
        _pagingController.appendPage(posts, nextPageKey);
      }
    } catch (error) {
      if (!_isDisposed) {
        _pagingController.error = error;
      }
    }
  }

  void _applyFilters() {
    _searchQuery = _searchController.text.isEmpty ? null : _searchController.text;
    _pagingController.refresh();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _searchController.dispose();
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Content',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.live_tv),
            tooltip: 'Manage Livestreams',
            onPressed: () {
              context.go('/admin/configure-content/livestream');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilterSection(),
          Expanded(
            child: RefreshIndicator(
              color: AppPallete.primaryColor,
              onRefresh: () async {
                _pagingController.refresh();
                return Future.value();
              },
              child: PagedListView<int, Post>(
                pagingController: _pagingController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                builderDelegate: PagedChildBuilderDelegate<Post>(
                  itemBuilder: (context, post, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: PostCardWidget(
                        post: post,
                        onDeleteSuccess: (Post post) {
                          if (_pagingController.itemList != null) {
                            final currentItems = List<Post>.from(_pagingController.itemList!);
                            currentItems.removeWhere((item) => item.id == post.id);
                            _pagingController.itemList = currentItems;
                          }
                        },
                      ),
                    );
                  },
                  firstPageProgressIndicatorBuilder: (_) => const CustomLoadingWidget(
                    title: 'Loading posts',
                    subtitle: 'Please wait while we load the posts',
                  ),
                  newPageProgressIndicatorBuilder: (_) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppPallete.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  firstPageErrorIndicatorBuilder: (context) => CustomErrorWidget(
                    title: 'Error loading posts',
                    onPressed: () => _pagingController.retryLastFailedRequest(),
                    error: _pagingController.error.toString(),
                  ),
                  newPageErrorIndicatorBuilder: (context) => CustomErrorWidget(
                    title: 'Error loading posts',
                    onPressed: () => _pagingController.retryLastFailedRequest(),
                    error: _pagingController.error.toString(),
                  ),
                  noItemsFoundIndicatorBuilder: (context) => _buildEmptyState(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppPallete.neutralColor.shade200.withAlpha(120),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by title or caption',
              prefixIcon: Icon(
                Icons.search,
                color: AppPallete.neutralColor.shade500,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.clear,
                  color: AppPallete.neutralColor.shade500,
                ),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = null;
                  });
                  _pagingController.refresh();
                },
              ),
              filled: true,
              fillColor: AppPallete.neutralColor.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            onSubmitted: (_) => _applyFilters(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppPallete.neutralColor.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<UserRole?>(
                      value: _selectedRole,
                      hint: Text(
                        'Filter by author role',
                        style: TextStyle(
                          color: AppPallete.neutralColor.shade500,
                          fontSize: 14,
                        ),
                      ),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: AppPallete.neutralColor.shade700,
                      ),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<UserRole?>(
                          value: null,
                          child: Text('All Roles'),
                        ),
                        ...UserRole.values.map((role) {
                          return DropdownMenuItem<UserRole?>(
                            value: role,
                            child: Text(role.name[0].toUpperCase() + role.name.substring(1)),
                          );
                        }),
                      ],
                      onChanged: (UserRole? value) {
                        setState(() {
                          _selectedRole = value;
                        });
                        _pagingController.refresh();
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPallete.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: AppPallete.neutralColor.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              'No Posts Found',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppPallete.neutralColor.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery != null || _selectedRole != null
                  ? 'No posts match your current filters. Try changing your search or filter criteria.'
                  : 'There are no posts in the system yet.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: AppPallete.neutralColor.shade600,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
