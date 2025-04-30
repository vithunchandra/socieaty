import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:socieaty/core/enums/user_role.enum.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';
import 'package:socieaty/features/user/provider/paginate_users_provider.dart';
import 'package:socieaty/features/user/repository/request/paginate_users_request_query.dart';
import 'package:socieaty/shared/models/pagination_query.dart';
import 'package:socieaty/shared/widgets/custom_error_widget.dart';
import 'package:socieaty/shared/widgets/custom_loading_widget.dart';
import 'package:socieaty/features/admin/view/widgets/user_card_widget.dart';

class ConfigureUserScreen extends ConsumerStatefulWidget {
  const ConfigureUserScreen({super.key});

  @override
  ConsumerState<ConfigureUserScreen> createState() => _ConfigureUserScreenState();
}

class _ConfigureUserScreenState extends ConsumerState<ConfigureUserScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PagingController<int, SocieatyUser> _pagingController = PagingController(firstPageKey: 0);
  final int _pageSize = 10;
  bool _isDisposed = false;

  UserRole? _selectedRole;
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchUsers(pageKey);
    });
  }

  Future<void> _fetchUsers(int pageKey) async {
    if (!mounted || _isDisposed) return;

    try {
      final query = PaginateUsersRequestQuery(
        paginationQuery: PaginationQuery(page: pageKey, pageSize: _pageSize),
        searchQuery: _searchQuery,
        role: _selectedRole,
      );

      final response = await ref.read(paginateUsersProvider(query).future);
      final users = response.users;
      final pagination = response.pagination;

      final isLastPage = !pagination.hasNext;

      if (isLastPage) {
        _pagingController.appendLastPage(users);
      } else {
        final nextPageKey = pagination.nextPage;
        _pagingController.appendPage(users, nextPageKey);
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
          'Manage Users',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
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
              child: PagedListView<int, SocieatyUser>(
                pagingController: _pagingController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                builderDelegate: PagedChildBuilderDelegate<SocieatyUser>(
                  itemBuilder: (context, user, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: UserCardWidget(
                        user: user,
                        onDeleteSuccess: (SocieatyUser user) {
                          _pagingController.itemList![index] = user;
                          setState(() {});
                        },
                      ),
                    );
                  },
                  firstPageProgressIndicatorBuilder: (_) => const CustomLoadingWidget(
                    title: 'Loading users',
                    subtitle: 'Please wait while we load the users',
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
                    title: 'Error loading users',
                    onPressed: () => _pagingController.retryLastFailedRequest(),
                    error: _pagingController.error.toString(),
                  ),
                  newPageErrorIndicatorBuilder: (context) => CustomErrorWidget(
                    title: 'Error loading users',
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
              hintText: 'Search by name or email',
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
                        'Filter by role',
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
              Icons.people_outline,
              size: 64,
              color: AppPallete.neutralColor.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              'No Users Found',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppPallete.neutralColor.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery != null || _selectedRole != null
                  ? 'No users match your current filters. Try changing your search or filter criteria.'
                  : 'There are no users in the system yet.',
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
