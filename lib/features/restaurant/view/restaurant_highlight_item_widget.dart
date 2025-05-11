import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/location_handler.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';
import 'package:socieaty/features/transaction_review/provider/get_all_restaurant_reviews_provider.dart';
import 'package:socieaty/shared/widgets/image_error_widget.dart';
import 'package:socieaty/shared/widgets/image_loading_widget.dart';

class RestaurantHighlightItemWidget extends ConsumerStatefulWidget {
  final SocieatyRestaurant restaurant;
  const RestaurantHighlightItemWidget({super.key, required this.restaurant});

  @override
  ConsumerState<RestaurantHighlightItemWidget> createState() =>
      _RestaurantHighlightItemWidgetState();
}

class _RestaurantHighlightItemWidgetState extends ConsumerState<RestaurantHighlightItemWidget> {
  String _locationName = "";

  @override
  void initState() {
    super.initState();
    getLocationName();
  }

  void getLocationName() async {
    var location =
        await LocationHandler.getAddressFromLatLng(widget.restaurant.restaurantData.location);
    _locationName = "${location?.street}";
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviewsAsync =
        ref.watch(getAllRestaurantReviewsProvider(widget.restaurant.restaurantData.id, null));

    return PhysicalModel(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      elevation: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: widget.restaurant.restaurantData.restaurantBannerUrl,
                fit: BoxFit.cover,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    imageLoadingWidget(context, url, downloadProgress),
                errorWidget: (context, url, error) => imageErrorWidget(context, error, null),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: [0.3, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.restaurant.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: const [
                          Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black)
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          _locationName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            shadows: const [
                              Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black)
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.category, color: AppPallete.primaryColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          widget.restaurant.restaurantData.themes.map((e) => e.name).join(', '),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      reviewsAsync.when(
                        data: (data) => data.rating.toStringAsFixed(1),
                        error: (error, stacktrace) => '-',
                        loading: () => '0',
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.star, color: Colors.white, size: 12),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
