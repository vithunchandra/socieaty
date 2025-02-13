import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/features/restaurant_menu/model/food_menu.dart';
import 'package:socieaty/shared/widgets/image_error_widget.dart';
import 'package:socieaty/shared/widgets/image_loading_widget.dart';

class FoodMenuItemViewWidget extends StatelessWidget {
  final FoodMenu restaurantMenu;
  const FoodMenuItemViewWidget({super.key, required this.restaurantMenu});

  @override
  Widget build(BuildContext context) {
    return  SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurantMenu.name.toCapitalized(),
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                    ),
                    SizedBox(height: 8),
                    Text(
                      restaurantMenu.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12),
                    Text("Rp ${restaurantMenu.price.toIDRFormat()}",
                        style: Theme.of(context).textTheme.titleSmall)
                  ],
                ),
              ),
              SizedBox(width: 24),
              Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 100,
                        padding: EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                              color:
                                  restaurantMenu.isStockAvailable ? AppPallete.successColor : AppPallete.errorColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(restaurantMenu.isStockAvailable ? "Tersedia" : "Kosong",
                                style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(width: 4),
                            Icon(restaurantMenu.isStockAvailable ? Icons.check_circle : Icons.close,
                                color: restaurantMenu.isStockAvailable
                                    ? AppPallete.successColor
                                    : AppPallete.errorColor,
                                size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CachedNetworkImage(
                        imageUrl: restaurantMenu.pictureUrl,
                        fit: BoxFit.cover,
                        progressIndicatorBuilder: (context, url, progress) =>
                            imageLoadingWidget(context, url, progress),
                        errorWidget: (context, url, error) =>
                            imageErrorWidget(context, error, null),
                        memCacheWidth: 240,
                        memCacheHeight: 240,
                        maxWidthDiskCache: 240,
                        maxHeightDiskCache: 240,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
  }
}