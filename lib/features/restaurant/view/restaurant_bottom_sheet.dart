import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/location_handler.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';
import 'package:socieaty/features/transaction_review/provider/get_all_restaurant_reviews_provider.dart';
import 'package:socieaty/shared/widgets/image_error_widget.dart';
import 'package:socieaty/shared/widgets/image_loading_widget.dart';

class RestaurantBottomSheet extends ConsumerStatefulWidget {
  final SocieatyRestaurant restaurant;
  final VoidCallback onViewDetailsPressed;
  final VoidCallback? onDismissed;

  const RestaurantBottomSheet({
    super.key,
    required this.restaurant,
    required this.onViewDetailsPressed,
    this.onDismissed,
  });

  @override
  ConsumerState<RestaurantBottomSheet> createState() => _RestaurantBottomSheetState();
}

class _RestaurantBottomSheetState extends ConsumerState<RestaurantBottomSheet> {
  String _locationAddress = "Lokasi restoran";

  @override
  void initState() {
    super.initState();
    _getRestaurantAddress();
  }

  void _getRestaurantAddress() async {
    final location = await LocationHandler.getAddressFromLatLng(
        widget.restaurant.restaurantData.location);
    if (location != null && mounted) {
      setState(() {
        _locationAddress = "${location.street}, ${location.locality}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = widget.restaurant;
    final reviewsAsync =
        ref.watch(getAllRestaurantReviewsProvider(widget.restaurant.restaurantData.id, null));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && widget.onDismissed != null) {
          widget.onDismissed!();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(top: 48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 12,
              offset: const Offset(0, -2),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: AppPallete.neutralColor.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            // Image Header
            Hero(
              tag: 'restaurant_${restaurant.id}',
              child: Container(
                height: 160,
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Restaurant Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: restaurant.restaurantData.restaurantBannerUrl,
                        fit: BoxFit.cover,
                        progressIndicatorBuilder: (context, url, progress) =>
                            imageLoadingWidget(context, url, progress),
                        errorWidget: (context, error, stackTrace) =>
                            imageErrorWidget(context, error, null),
                      ),
                    ),

                    // Gradient overlay for text readability
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withAlpha(160),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),

                    // Rating badge
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(30),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: AppPallete.primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              reviewsAsync.when(
                                data: (data) => data.rating.toStringAsFixed(1),
                                error: (error, stackTrace) => '-',
                                loading: () => '-',
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppPallete.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Restaurant name
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurant.name,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withAlpha(100),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Restaurant Info
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info cards row
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        // Hours
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppPallete.primaryColor.withAlpha(8),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppPallete.primaryColor.withAlpha(20),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 16,
                                      color: AppPallete.primaryColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Jam Buka',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppPallete.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${restaurant.restaurantData.openTime} - ${restaurant.restaurantData.closeTime}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppPallete.neutralColor.shade800,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Location
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppPallete.primaryColor.withAlpha(8),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppPallete.primaryColor.withAlpha(20),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_rounded,
                                      size: 16,
                                      color: AppPallete.primaryColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Lokasi',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppPallete.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _locationAddress,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppPallete.neutralColor.shade800,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Categories
                  if (restaurant.restaurantData.themes.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.local_dining_rounded,
                          size: 16,
                          color: AppPallete.neutralColor.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Kategori',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppPallete.neutralColor.shade800,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.restaurant.restaurantData.themes
                          .take(4) // Limit to 4 categories for better UI
                          .map((theme) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppPallete.primaryColor.withAlpha(12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppPallete.primaryColor.withAlpha(40),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  theme.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppPallete.primaryColor,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: widget.onViewDetailsPressed,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0.5,
                      ),
                      icon: const Icon(Icons.restaurant_rounded, size: 20),
                      label: const Text(
                        'Lihat Detail Restoran',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
