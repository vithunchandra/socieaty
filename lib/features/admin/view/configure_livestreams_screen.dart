import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/enums/user_role.enum.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/admin/view/widgets/livestream_card_widget.dart';
import 'package:socieaty/features/livestream/provider/livestream_room_provider.dart';
import 'package:socieaty/features/livestream/repository/request/get_all_livestream_request_query.dart';
import 'package:socieaty/shared/widgets/custom_error_widget.dart';
import 'package:socieaty/shared/widgets/custom_loading_widget.dart';

class ConfigureLivestreamsScreen extends ConsumerStatefulWidget {
  const ConfigureLivestreamsScreen({super.key});

  @override
  ConsumerState<ConfigureLivestreamsScreen> createState() => _ConfigureLivestreamsScreenState();
}

class _ConfigureLivestreamsScreenState extends ConsumerState<ConfigureLivestreamsScreen> {
  final TextEditingController _searchController = TextEditingController();

  UserRole? _selectedRole;
  String? _searchQuery;
  late GetAllLivestreamRequestQuery _query;

  @override
  void initState() {
    super.initState();
    _query = GetAllLivestreamRequestQuery(
      searchQuery: _searchQuery,
      role: _selectedRole,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateQuery() {
    setState(() {
      _query = GetAllLivestreamRequestQuery(
        searchQuery: _searchQuery,
        role: _selectedRole,
      );
    });
  }

  void _applyFilters() {
    ref.invalidate(getLivestreamRoomsProvider(_query));
    setState(() {
      _searchQuery = _searchController.text.isEmpty ? null : _searchController.text;
    });
    _updateQuery();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final livestreamsAsync = ref.watch(getLivestreamRoomsProvider(_query));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Livestreams',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.article_outlined),
            tooltip: 'Manage Content',
            onPressed: () {
              context.go('/admin/configure-content');
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
                return ref.refresh(getLivestreamRoomsProvider(_query).future);
              },
              child: livestreamsAsync.when(
                data: (livestreams) {
                  debugPrint('livestreams: $livestreams');
                  if (livestreams.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: livestreams.length,
                    itemBuilder: (context, index) {
                      final livestream = livestreams[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: LivestreamCardWidget(
                          liveRoom: livestream,
                          onDeleteSuccess: (liveRoom) {
                            debugPrint("Hallloooo");
                            ref.invalidate(getLivestreamRoomsProvider(_query));
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => const CustomLoadingWidget(
                  title: 'Loading livestreams',
                  subtitle: 'Please wait while we load the livestreams',
                ),
                error: (error, stackTrace) => CustomErrorWidget(
                  title: 'Error loading livestreams',
                  onPressed: () => ref.invalidate(getLivestreamRoomsProvider(_query)),
                  error: error.toString(),
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
              hintText: 'Search by title',
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
                  _updateQuery();
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
                        _updateQuery();
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
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.live_tv_outlined,
                size: 64,
                color: AppPallete.neutralColor.shade300,
              ),
              const SizedBox(height: 24),
              Text(
                'No Livestreams Found',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppPallete.neutralColor.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _searchQuery != null || _selectedRole != null
                    ? 'No livestreams match your current filters. Try changing your search or filter criteria.'
                    : 'There are no livestreams in the system yet.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppPallete.neutralColor.shade600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
