import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/location_handler.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';
import 'package:socieaty/shared/widgets/image_error_widget.dart';
import 'package:socieaty/shared/widgets/image_loading_widget.dart';

class OutletSuggestionItemWidget extends StatefulWidget {
  final SocieatyRestaurant restaurant;
  const OutletSuggestionItemWidget({super.key, required this.restaurant});

  @override
  State<OutletSuggestionItemWidget> createState() => _OutletSuggestionItemWidgetState();
}

class _OutletSuggestionItemWidgetState extends State<OutletSuggestionItemWidget> {
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
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppPallete.neutralColor.shade400.withAlpha(128),
            blurRadius: 4,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            context.push('/${widget.restaurant.id}');
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Hero(
                  tag: 'restaurant_${widget.restaurant.id}',
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: widget.restaurant.restaurantData.restaurantBannerUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: widget.restaurant.restaurantData.restaurantBannerUrl,
                              width: 76,
                              height: 76,
                              fit: BoxFit.cover,
                              progressIndicatorBuilder: (context, url, downloadProgress) =>
                                  imageLoadingWidget(context, url, downloadProgress),
                              errorWidget: (context, url, error) =>
                                  imageErrorWidget(context, error, null),
                            )
                          : Container(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              child: Icon(
                                Icons.restaurant_rounded,
                                size: 32,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Restaurant Details
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.restaurant.name,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_pin,
                            size: 14,
                            color: AppPallete.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _locationName,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.category_rounded,
                            size: 14,
                            color: AppPallete.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.restaurant.restaurantData.themes
                                .map((theme) => theme.name)
                                .join(', '),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
