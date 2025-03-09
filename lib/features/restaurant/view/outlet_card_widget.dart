import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/location_handler.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';
import 'package:socieaty/shared/widgets/image_error_widget.dart';
import 'package:socieaty/shared/widgets/image_loading_widget.dart';

class OutletCardWidget extends StatefulWidget {
  final SocieatyRestaurant restaurant;

  const OutletCardWidget({super.key, required this.restaurant});

  @override
  State<OutletCardWidget> createState() => _OutletCardWidgetState();
}

class _OutletCardWidgetState extends State<OutletCardWidget> {
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.restaurant.restaurantData.restaurantBannerUrl,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                    progressIndicatorBuilder: (context, url, downloadProgress) =>
                        imageLoadingWidget(context, url, downloadProgress),
                    errorWidget: (context, url, error) => imageErrorWidget(context, error, null),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Open Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [
                          Text(
                            '4.2',
                            style: TextStyle(
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
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.restaurant.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.redAccent, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _locationName,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ...widget.restaurant.restaurantData.themes.map(
                        (category) => Chip(
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          labelPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                          label: Text(
                            'Desserts',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          backgroundColor: AppPallete.primaryColor,
                          side: BorderSide(color: AppPallete.primaryColor, width: 1),
                        ),
                      ),
                    ],
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
