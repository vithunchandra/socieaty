import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/location_handler.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class RestaurantLocationScreenArgs {
  final LatLng location;
  final String restaurantName;

  RestaurantLocationScreenArgs({required this.location, required this.restaurantName});
}

class RestaurantLocationScreen extends StatefulWidget {
  final RestaurantLocationScreenArgs args;

  const RestaurantLocationScreen({
    super.key,
    required this.args,
  });

  @override
  State<RestaurantLocationScreen> createState() => _RestaurantLocationScreenState();
}

class _RestaurantLocationScreenState extends State<RestaurantLocationScreen> {
  late GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  String _address = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getLocationDetails();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _getLocationDetails() async {
    setState(() {
      _isLoading = true;
    });

    // Get address from the coordinates
    final locationData = await LocationHandler.getAddressFromLatLng(widget.args.location);

    if (locationData != null && mounted) {
      setState(() {
        _address = "${locationData.street}, ${locationData.subLocality}, ${locationData.locality}";
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        _address = "Address not available";
        _isLoading = false;
      });
    }

    // Create marker for the restaurant location
    if (mounted) {
      setState(() {
        _markers.add(
          Marker(
            markerId: const MarkerId('restaurant_location'),
            position: widget.args.location,
            infoWindow: InfoWindow(
              title: widget.args.restaurantName,
              snippet: _address,
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.args.restaurantName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.args.location,
              zoom: 15,
            ),
            markers: _markers,
            onMapCreated: (controller) {
              setState(() {
                _mapController = controller;
              });
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
            zoomControlsEnabled: true,
          ),
          if (_isLoading)
            const Center(
              child: LoadingIndicatorWidget(size: 48),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(30),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppPallete.primaryColor.withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: AppPallete.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.args.restaurantName,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isLoading ? "Loading address..." : _address,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            // Open directions in Google Maps app
                            // This functionality can be added if needed
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fitur Arah akan segera hadir'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.directions),
                          label: const Text('Arah'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppPallete.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
