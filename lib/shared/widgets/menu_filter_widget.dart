import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/food_menu/provider/get_all_food_menu_categories_provider.dart';
import 'package:socieaty/shared/widgets/dotted_divider.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

part 'menu_filter_widget.freezed.dart';
part 'menu_filter_widget.g.dart';

Future<MenuFilterFormState?> showFilterBottomSheet(
    BuildContext context, MenuFilterFormState filterState) async {
  final result = await showModalBottomSheet<MenuFilterFormState>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return MenuFilterWidget(initialFilterState: filterState);
    },
  );
  return result;
}

class MenuFilterWidget extends ConsumerStatefulWidget {
  final MenuFilterFormState initialFilterState;
  const MenuFilterWidget({super.key, required this.initialFilterState});

  @override
  ConsumerState<MenuFilterWidget> createState() => _MenuFilterWidgetState();
}

class _MenuFilterWidgetState extends ConsumerState<MenuFilterWidget> {
  late List<String> _selectedPriceRanges;
  late double _minRating;
  late List<int> _selectedCategories;
  final List<Map<String, dynamic>> _priceRanges = [
    {'id': 'CONDITION_1', 'label': 'Kurang dari Rp10.000'},
    {'id': 'CONDITION_2', 'label': 'Rp10.000 sampai Rp25.000'},
    {'id': 'CONDITION_3', 'label': 'Rp25.000 sampai Rp70.000'},
    {'id': 'CONDITION_4', 'label': 'Rp70.000 sampai Rp150.000'},
    {'id': 'CONDITION_5', 'label': 'Lebih dari Rp150.000'},
  ];
  late MenuFilterFormState? _menuFilterFormState;

  @override
  void initState() {
    super.initState();
    // Initialize state with values from initialFilterState
    _selectedPriceRanges = List.from(widget.initialFilterState.priceRanges);
    _minRating = widget.initialFilterState.minRating;
    _selectedCategories = List.from(widget.initialFilterState.categories);
    _menuFilterFormState = widget.initialFilterState;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    void pop() {
      _menuFilterFormState = _menuFilterFormState?.copyWith(
        priceRanges: _selectedPriceRanges,
        minRating: _minRating,
        categories: _selectedCategories,
      );
      debugPrint('menuFilterFormState: $_menuFilterFormState');
      context.pop(_menuFilterFormState);
    }

    final menuCategories = ref.watch(getAllFoodMenuCategoriesProvider);

    return ref.watch(getAllFoodMenuCategoriesProvider).isLoading
        ? SizedBox(
            height: screenHeight * 0.7,
            child: LoadingIndicatorWidget(),
          )
        : Container(
            height: screenHeight * 0.8,
            decoration: BoxDecoration(
              color: AppPallete.neutralColor.shade50,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: AppPallete.neutralColor.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Filter Menu',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          const DottedDivider(
                            height: 0.5,
                            color: AppPallete.neutralColor,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Price Range',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          ..._priceRanges.map(
                            (range) => Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: _selectedPriceRanges.contains(range['id'])
                                    ? AppPallete.primaryColor.withOpacity(0.1)
                                    : Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppPallete.neutralColor.shade200.withOpacity(0.5),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: CheckboxListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                title: Text(
                                  range['label']!,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: _selectedPriceRanges.contains(range['id'])
                                            ? AppPallete.primaryColor
                                            : AppPallete.neutralColor.shade800,
                                      ),
                                ),
                                value: _selectedPriceRanges.contains(range['id']),
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedPriceRanges.add(range['id']!);
                                    } else {
                                      _selectedPriceRanges.remove(range['id']!);
                                    }
                                  });
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                checkboxShape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                activeColor: AppPallete.primaryColor,
                                checkColor: Colors.white,
                                side: BorderSide(
                                  color: AppPallete.neutralColor.shade300,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Minimum Rating',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: AppPallete.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _minRating.toStringAsFixed(1),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          Slider(
                            value: _minRating,
                            min: 0,
                            max: 5,
                            divisions: 10,
                            onChanged: (double value) {
                              setState(() {
                                _minRating = value;
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Categories',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: menuCategories.when(
                              data: (value) {
                                return value.map((theme) {
                                  final isSelected = _selectedCategories.contains(theme.id);
                                  return FilterChip(
                                    selected: isSelected,
                                    label: Text(theme.name),
                                    onSelected: (bool selected) {
                                      setState(() {
                                        if (selected) {
                                          _selectedCategories.add(theme.id);
                                        } else {
                                          _selectedCategories.remove(theme.id);
                                        }
                                      });
                                    },
                                    backgroundColor: Colors.white,
                                    selectedColor: AppPallete.primaryColor,
                                    checkmarkColor: Colors.white,
                                    side: BorderSide(
                                      color: isSelected
                                          ? AppPallete.primaryColor
                                          : AppPallete.neutralColor.shade300,
                                    ),
                                  );
                                }).toList();
                              },
                              error: (error, stacktrace) {
                                showSnackbar(context, error.toString(), isError: true);
                                return [];
                              },
                              loading: () {
                                return [];
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Action buttons in a fixed bottom area
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppPallete.neutralColor.shade50,
                    boxShadow: [
                      BoxShadow(
                        color: AppPallete.neutralColor.shade200,
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _selectedPriceRanges.clear();
                              _minRating = 0;
                              _selectedCategories.clear();
                            });
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            // Implement filter logic here
                            pop();
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}

@freezed
class MenuFilterFormState with _$MenuFilterFormState {
  const factory MenuFilterFormState({
    @Default([]) List<String> priceRanges,
    @Default(0) double minRating,
    @Default([]) List<int> categories,
    @Default('') String searchQuery,
  }) = _MenuFilterFormState;

  factory MenuFilterFormState.fromJson(Map<String, dynamic> json) =>
      _$MenuFilterFormStateFromJson(json);
}
