import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/restaurant/model/restaurant_theme.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';
import 'package:socieaty/features/restaurant/provider/get_all_restaurant_themes_provider.dart';
import 'package:socieaty/features/restaurant/provider/get_all_unverified_restaurant_provider.dart';
import 'package:socieaty/features/restaurant/repository/request/get_all_unverified_restaurant_request_query.dart';
import 'package:socieaty/shared/widgets/custom_error_widget.dart';
import 'package:socieaty/shared/widgets/custom_loading_widget.dart';
import 'package:socieaty/features/admin/view/widgets/unverified_restaurant_card_widget.dart';

class ConfigureUnverifiedRestaurantScreen extends ConsumerStatefulWidget {
  const ConfigureUnverifiedRestaurantScreen({super.key});

  @override
  ConsumerState<ConfigureUnverifiedRestaurantScreen> createState() =>
      _ConfigureUnverifiedRestaurantScreenState();
}

class _ConfigureUnverifiedRestaurantScreenState
    extends ConsumerState<ConfigureUnverifiedRestaurantScreen> {
  final TextEditingController _searchController = TextEditingController();

  String? _searchQuery;
  List<int> _selectedThemes = [];
  late GetAllUnverifiedRestaurantRequestQuery _query;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _updateQueryObject();
  }

  void _updateQueryObject() {
    _query = GetAllUnverifiedRestaurantRequestQuery(
      name: _searchQuery,
      themes: _selectedThemes,
    );
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.isEmpty ? null : _searchController.text;
      _updateQueryObject();
    });
  }

  void _applyFilters() {
    setState(() {
      _searchQuery = _searchController.text.isEmpty ? null : _searchController.text;
      _updateQueryObject();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final restaurantsAsyncValue = ref.watch(getAllUnverifiedRestaurantProvider(_query));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Unverified Restaurants',
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
              onRefresh: () {
                setState(() {
                  _updateQueryObject();
                });
                return Future.value();
              },
              child: restaurantsAsyncValue.when(
                data: (restaurants) {
                  if (restaurants.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    physics: const BouncingScrollPhysics(),
                    itemCount: restaurants.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: UnverifiedRestaurantCardWidget(
                          restaurant: restaurants[index],
                          onVerifySuccess: () {
                            setState(() {
                              _updateQueryObject();
                            });
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => const CustomLoadingWidget(
                  title: 'Loading restaurants',
                  subtitle: 'Please wait while we load the unverified restaurants',
                ),
                error: (error, stackTrace) => CustomErrorWidget(
                  title: 'Error loading restaurants',
                  onPressed: () => setState(() {
                    _updateQueryObject();
                  }),
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
              hintText: 'Search by restaurant name',
              prefixIcon: Icon(
                Icons.search,
                color: AppPallete.neutralColor.shade500,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: AppPallete.neutralColor.shade500,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = null;
                        });
                      },
                    ),
                  IconButton(
                    icon: Icon(
                      Icons.filter_list,
                      color: AppPallete.neutralColor.shade500,
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => _buildThemeFilterSheet(),
                      );
                    },
                  ),
                ],
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
        ],
      ),
    );
  }

  Widget _buildThemeFilterSheet() {
    final themesAsyncValue = ref.watch(getAllRestaurantThemesProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Theme',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Select themes to filter restaurants',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppPallete.neutralColor.shade600,
                ),
          ),
          const SizedBox(height: 16),
          themesAsyncValue.when(
            data: (themes) {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Clear All'),
                    selected: _selectedThemes.isEmpty,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedThemes = [];
                          _updateQueryObject();
                        });
                        Navigator.pop(context);
                      }
                    },
                  ),
                  ...themes.map((theme) {
                    final isSelected = _selectedThemes.contains(theme.id);
                    return FilterChip(
                      label: Text(theme.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedThemes.add(theme.id);
                          } else {
                            _selectedThemes.remove(theme.id);
                          }
                          _updateQueryObject();
                        });
                      },
                    );
                  }),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (_, __) => const Text('Error loading themes'),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _selectedThemes = [];
                    _updateQueryObject();
                  });
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppPallete.neutralColor.shade300),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                child: Text(
                  'Clear All',
                  style: TextStyle(color: AppPallete.neutralColor.shade700),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPallete.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
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
              Icons.restaurant,
              size: 64,
              color: AppPallete.neutralColor.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              'No Unverified Restaurants',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppPallete.neutralColor.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery != null || _selectedThemes.isNotEmpty
                  ? 'No restaurants match your current filters. Try changing your search or filter criteria.'
                  : 'There are no unverified restaurants in the system at the moment.',
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
