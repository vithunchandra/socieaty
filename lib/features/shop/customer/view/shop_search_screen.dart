import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/restaurant/provider/paginate_restaurant_provider.dart';
import 'package:socieaty/features/restaurant/view/outlet_suggestion_item_widget.dart';
import 'package:socieaty/features/restaurant/viewstate/paginate_restaurant_query_state.dart';
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurants = ref.watch(paginateRestaurantProvider(_queryState));

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
                    onTap: () => Navigator.pop(context),
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
              child: Text(
                'Recent Searches',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            const SizedBox(height: 16),
            _buildRecentSearchItem(
              'Pizza Restaurants',
              Icons.history,
              onTap: () {},
            ),
            _buildRecentSearchItem(
              'Burger King',
              Icons.history,
              onTap: () {},
            ),
            _buildRecentSearchItem(
              'Chinese Food',
              Icons.history,
              onTap: () {},
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

  Widget _buildRecentSearchItem(String text, IconData icon, {VoidCallback? onTap}) {
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildCategoryChip('🍕 Pizza'),
          _buildCategoryChip('🍔 Burgers'),
          _buildCategoryChip('🍜 Chinese'),
          _buildCategoryChip(' Sushi'),
          _buildCategoryChip('🥗 Healthy'),
          _buildCategoryChip('☕️ Coffee'),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    return FilterChip(
      label: Text(label),
      onSelected: (_) {},
      backgroundColor: AppPallete.neutralColor.shade100,
      labelStyle: TextStyle(
        color: AppPallete.neutralColor.shade700,
        fontSize: 14,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
