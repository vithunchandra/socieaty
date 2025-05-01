import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/restaurant/model/restaurant_theme.dart';
import 'package:socieaty/features/restaurant/provider/get_all_restaurant_themes_provider.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class RestaurantThemeFilterSheet extends ConsumerStatefulWidget {
  final List<int> initialSelectedThemes;
  final Function(List<int>) onApply;

  const RestaurantThemeFilterSheet({
    super.key,
    required this.initialSelectedThemes,
    required this.onApply,
  });

  @override
  ConsumerState<RestaurantThemeFilterSheet> createState() => _RestaurantThemeFilterSheetState();
}

class _RestaurantThemeFilterSheetState extends ConsumerState<RestaurantThemeFilterSheet> {
  late List<int> _selectedThemes;

  @override
  void initState() {
    super.initState();
    _selectedThemes = List.from(widget.initialSelectedThemes);
  }

  void _clearSelections() {
    setState(() {
      _selectedThemes = [];
    });
  }

  void _toggleTheme(int themeId, bool selected) {
    setState(() {
      if (selected) {
        _selectedThemes.add(themeId);
      } else {
        _selectedThemes.remove(themeId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          Consumer(
            builder: (context, ref, child) {
              final themesAsyncValue = ref.watch(getAllRestaurantThemesProvider);

              return themesAsyncValue.when(
                data: (themes) {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Clear All'),
                        selected: _selectedThemes.isEmpty,
                        backgroundColor: Colors.white,
                        selectedColor: AppPallete.primaryColor,
                        checkmarkColor: Colors.white,
                        showCheckmark: false,
                        side: BorderSide(
                          color: _selectedThemes.isEmpty
                              ? AppPallete.primaryColor
                              : AppPallete.neutralColor.shade300,
                        ),
                        onSelected: (selected) {
                          _clearSelections();
                        },
                      ),
                      ...themes.map((theme) {
                        final isSelected = _selectedThemes.contains(theme.id);
                        return FilterChip(
                          label: Text(theme.name),
                          selected: isSelected,
                          backgroundColor: Colors.white,
                          selectedColor: AppPallete.primaryColor,
                          checkmarkColor: Colors.white,
                          showCheckmark: false,
                          side: BorderSide(
                            color: isSelected
                                ? AppPallete.primaryColor
                                : AppPallete.neutralColor.shade300,
                          ),
                          onSelected: (selected) {
                            _toggleTheme(theme.id, selected);
                          },
                        );
                      }),
                    ],
                  );
                },
                loading: () => const Center(
                  child: LoadingIndicatorWidget(size: 24),
                ),
                error: (_, __) => const Text('Error loading themes'),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () {
                  _clearSelections();
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
                  widget.onApply(_selectedThemes);
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
}
