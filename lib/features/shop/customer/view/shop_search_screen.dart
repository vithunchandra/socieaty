import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/food_menu/provider/get_menu_categories_by_popularity_provider.dart';
import 'package:socieaty/features/restaurant/provider/paginate_restaurant_provider.dart';
import 'package:socieaty/features/restaurant/view/outlet_suggestion_item_widget.dart';
import 'package:socieaty/features/restaurant/viewstate/paginate_restaurant_query_state.dart';
import 'package:socieaty/features/shop/customer/provider/recent_searches_provider.dart';
import 'package:socieaty/features/shop/customer/repository/search_local_repository.dart';
import 'package:socieaty/shared/widgets/custom_error_widget.dart';
import 'package:socieaty/shared/widgets/restaurant_filter_widget.dart';

class ShopSearchScreen extends ConsumerStatefulWidget {
  const ShopSearchScreen({super.key});

  @override
  ConsumerState<ShopSearchScreen> createState() => _ShopSearchScreenState();
}

class _ShopSearchScreenState extends ConsumerState<ShopSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  PaginateRestaurantQueryState _queryState = PaginateRestaurantQueryState();

  @override
  void initState() {
    super.initState();
    // The repository is now initialized in the provider
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch() async {
    final searchTerm = _searchController.text.trim();
    if (searchTerm.isNotEmpty) {
      // Add to recent searches
      await ref.read(recentSearchesControllerProvider).addSearch(searchTerm);
      // Invalidate the provider to refresh the list
      ref.invalidate(recentSearchesProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurants = ref.watch(paginateRestaurantProvider(_queryState));
    final recentSearchesAsync = ref.watch(recentSearchesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() {
                _queryState = _queryState.copyWith(name: value);
              }),
              onSubmitted: (_) => _submitSearch(),
              autofocus: true,
              style: TextStyle(
                fontSize: 16,
                color: AppPallete.neutralColor.shade800,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppPallete.neutralColor.shade200,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppPallete.neutralColor.shade200,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppPallete.primaryColor,
                    width: 1.5,
                  ),
                ),
                hintText: 'Search for restaurants...',
                hintStyle: TextStyle(
                  color: AppPallete.neutralColor.shade400,
                  fontSize: 16,
                  height: 1.5,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 4),
                  child: GestureDetector(
                    onTap: () => context.pop(context),
                    behavior: HitTestBehavior.opaque,
                    child: Icon(
                      Icons.arrow_back,
                      color: AppPallete.neutralColor.shade700,
                      size: 22,
                    ),
                  ),
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final newQueryState =
                              await showRestaurantFilterBottomSheet(context, _queryState);
                          if (newQueryState != null) {
                            setState(() {
                              _queryState = newQueryState;
                            });
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Icon(
                          Icons.tune,
                          size: 22,
                          color: AppPallete.neutralColor.shade700,
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _searchController.clear();
                                _queryState = _queryState.copyWith(name: '');
                              });
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Icon(
                              Icons.close,
                              color: AppPallete.neutralColor.shade700,
                              size: 22,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          if (_searchController.text.isEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Searches',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  recentSearchesAsync.when(
                    data: (recentSearches) => recentSearches.isNotEmpty
                        ? GestureDetector(
                            onTap: () async {
                              await ref.read(recentSearchesControllerProvider).clearSearches();
                              ref.invalidate(recentSearchesProvider);
                            },
                            child: Text(
                              'Clear All',
                              style: TextStyle(
                                color: AppPallete.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            recentSearchesAsync.when(
              data: (recentSearches) {
                if (recentSearches.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'No recent searches',
                      style: TextStyle(
                        color: AppPallete.neutralColor.shade400,
                        fontSize: 14,
                      ),
                    ),
                  );
                }
                return Column(
                  children: recentSearches
                      .take(3)
                      .map((searchTerm) => _buildRecentSearchItem(
                            searchTerm,
                            Icons.history,
                            onTap: () {
                              setState(() {
                                _searchController.text = searchTerm;
                                _queryState = _queryState.copyWith(name: searchTerm);
                              });
                            },
                            onDelete: () async {
                              await ref
                                  .read(recentSearchesControllerProvider)
                                  .removeSearch(searchTerm);
                              ref.invalidate(recentSearchesProvider);
                            },
                          ))
                      .toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              error: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Could not load recent searches',
                  style: TextStyle(
                    color: AppPallete.neutralColor.shade400,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Popular Categories',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            const SizedBox(height: 16),
            _buildPopularCategories(),
            const SizedBox(height: 24),
          ],
          restaurants.when(
            data: (data) => ListView.builder(
              itemCount: data.restaurants.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) =>
                  OutletSuggestionItemWidget(restaurant: data.restaurants[index]),
            ),
            error: (error, stack) => CustomErrorWidget(
              title: 'Restaurant',
              error: error.toString(),
              onPressed: () => ref.refresh(paginateRestaurantProvider(_queryState)),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildRecentSearchItem(String text, IconData icon,
      {VoidCallback? onTap, VoidCallback? onDelete}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: AppPallete.neutralColor.shade400,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: AppPallete.neutralColor.shade600,
                  fontSize: 14,
                ),
              ),
            ),
            if (onDelete != null)
              GestureDetector(
                onTap: onDelete,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: AppPallete.neutralColor.shade400,
                  ),
                ),
              )
            else
              Icon(
                Icons.north_west,
                size: 16,
                color: AppPallete.neutralColor.shade400,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularCategories() {
    final popularCategoriesAsync = ref.watch(getMenuCategoriesByPopularityProvider);

    return popularCategoriesAsync.when(
      data: (categories) {
        final topFiveCategories = categories.take(5).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: topFiveCategories.map((category) {
              return _buildCategoryChip(category.name, category.id);
            }).toList(),
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.0),
          ),
        ),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          'Could not load categories',
          style: TextStyle(
            color: AppPallete.neutralColor.shade600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, int categoryId) {
    final isSelected = _queryState.foodCategories.contains(categoryId);

    return FilterChip(
      label: Text(label),
      onSelected: (_) {
        setState(() {
          if (isSelected) {
            _queryState = _queryState.copyWith(
              foodCategories: List.from(_queryState.foodCategories)..remove(categoryId),
            );
          } else {
            _queryState = _queryState.copyWith(
              foodCategories: List.from(_queryState.foodCategories)..add(categoryId),
            );
          }
        });
      },
      selected: isSelected,
      backgroundColor: AppPallete.neutralColor.shade100,
      selectedColor: AppPallete.primaryColor.withOpacity(0.1),
      checkmarkColor: AppPallete.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? AppPallete.primaryColor : AppPallete.neutralColor.shade700,
        fontSize: 14,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
