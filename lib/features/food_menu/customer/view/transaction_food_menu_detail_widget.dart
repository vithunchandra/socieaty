import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/features/food_menu/model/food_menu.dart';
import 'package:socieaty/shared/widgets/image_error_widget.dart';
import 'package:socieaty/shared/widgets/image_loading_widget.dart';

class TransactionFoodMenuDetailWidget extends ConsumerStatefulWidget {
  final FoodMenu restaurantMenu;
  const TransactionFoodMenuDetailWidget({
    super.key,
    required this.restaurantMenu,
  });

  @override
  ConsumerState<TransactionFoodMenuDetailWidget> createState() => _TransactionFoodMenuDetailWidgetState();
}

class _TransactionFoodMenuDetailWidgetState extends ConsumerState<TransactionFoodMenuDetailWidget> {
  late FoodMenu _menu;
  // bool _isAvailable = false;

  @override
  void initState() {
    super.initState();
    _menu = widget.restaurantMenu;
    // _isAvailable = _menu.isStockAvailable;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      width: double.infinity,
      height: screenHeight * 0.8,
      child: Column(
        children: [
          // Drag indicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image section
                    Hero(
                      tag: widget.restaurantMenu.id,
                      child: Container(
                        width: double.infinity,
                        height: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CachedNetworkImage(
                            imageUrl: _menu.pictureUrl,
                            fit: BoxFit.cover,
                            progressIndicatorBuilder: (context, url, progress) =>
                                imageLoadingWidget(context, url, progress),
                            errorWidget: (context, error, stackTrace) =>
                                imageErrorWidget(context, error, null),
                            useOldImageOnUrlChange: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Menu information
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _menu.name,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 16,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${_menu.estimatedTime} menit",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Rp ${_menu.price.toIDRFormat()}",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ..._menu.categories.map((category) {
                          return Chip(
                            label: Text(
                              category.name,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppPallete.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            backgroundColor: AppPallete.primaryColor.shade200.withOpacity(0.1),
                            side: BorderSide(
                              color: AppPallete.primaryColor.withOpacity(0.2),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: -2,
                            ),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          );
                        })
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Description
                    Text(
                      "Description",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _menu.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppPallete.neutralColor.shade500,
                            height: 1.5,
                          ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
