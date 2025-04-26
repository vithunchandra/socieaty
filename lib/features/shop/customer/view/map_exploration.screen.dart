import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/location_handler.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';
import 'package:socieaty/features/restaurant/provider/get_nearest_restaurant_provider.dart';
import 'package:socieaty/features/restaurant/repository/request/get_nearest_restaurant_request_query.dart';
import 'package:socieaty/features/restaurant/view/restaurant_bottom_sheet.dart';
import 'package:socieaty/shared/widgets/custom_error_widget.dart';
import 'package:socieaty/shared/widgets/custom_loading_widget.dart';

class MapExplorationScreen extends ConsumerStatefulWidget {
  const MapExplorationScreen({super.key});

  @override
  ConsumerState<MapExplorationScreen> createState() => _MapExplorationScreenState();
}

class _MapExplorationScreenState extends ConsumerState<MapExplorationScreen> {
  GoogleMapController? _mapController;
  late LatLng _userLocation = const LatLng(-6.200000, 106.816666); // Default to Jakarta
  late LatLng _cameraCenter = _userLocation;
  final Set<Marker> _markers = {};
  double _searchRadius = 2000; // Default 2km radius
  double _currentZoom = 15.0;
  bool _isLoadingRestaurants = false;
  bool _isFirstLoading = true;
  bool _isError = false;
  List<SocieatyRestaurant> _restaurants = [];
  SocieatyRestaurant? _selectedRestaurant;
  bool _isMapIdle = true;
  Timer? _debounceTimer;

  // Custom map style to hide landmarks
  static const String _mapStyle = '''
  [
    {
      "featureType": "poi",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    },
    {
      "featureType": "poi.park",
      "stylers": [
        {
          "visibility": "on"
        }
      ]
    },
    {
      "featureType": "transit",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    }
  ]
  ''';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    LocationData? locationData = await LocationHandler.getCurrentPosition();
    if (locationData != null && mounted) {
      setState(() {
        _userLocation = LatLng(locationData.latitude!, locationData.longitude!);
        _cameraCenter = _userLocation; // Initially, camera center is user location
      });
      _animateToUserLocation();
      _fetchNearbyRestaurants();
    }
  }

  void _animateToUserLocation() {
    _mapController
        ?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _userLocation, zoom: 15),
      ),
    )
        .then((_) {
      if (mounted) {
        _updateCameraCenter();
      }
    });
  }

  Future<void> _updateCameraCenter() async {
    if (_mapController != null) {
      LatLng center = await _mapController!.getVisibleRegion().then((bounds) {
        return LatLng(
          (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
          (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
        );
      });

      setState(() {
        _cameraCenter = center;
      });
    }
  }

  double _calculateRadiusFromZoom(double zoom) {
    // Calculate radius (in meters) based on zoom level
    // Lower zoom = larger radius, higher zoom = smaller radius
    // These values can be adjusted based on your requirements
    return 20000 * math.pow(0.5, zoom - 10).toDouble();
  }

  void _updateRadiusFromZoom() {
    if (_mapController != null) {
      _mapController!.getZoomLevel().then((zoom) {
        setState(() {
          _currentZoom = zoom;
          _searchRadius = _calculateRadiusFromZoom(zoom);
        });
      });
    }
  }

  void _debouncedFetchRestaurants() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        _fetchNearbyRestaurants();
      }
    });
  }

  Future<void> _fetchNearbyRestaurants() async {
    if (!mounted) return;

    setState(() {
      _isLoadingRestaurants = true;
    });

    try {
      final query = GetNearestRestaurantRequestQuery(
        latitude: _cameraCenter.latitude,
        longitude: _cameraCenter.longitude,
        radius: _searchRadius,
      );

      final newRestaurants = await ref.read(getNearestRestaurantProvider(query).future);

      if (mounted) {
        // Add only new unique restaurants to our accumulated list
        final List<SocieatyRestaurant> updatedList = [..._restaurants];
        for (final restaurant in newRestaurants) {
          if (!_restaurants.any((r) => r.id == restaurant.id)) {
            updatedList.add(restaurant);
          }
        }

        setState(() {
          _restaurants = updatedList;
          _updateMarkers();
          _isLoadingRestaurants = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isError = true;
          _isLoadingRestaurants = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading restaurants: ${error.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isFirstLoading = false;
      });
    }
  }

  void _onMarkerTapped(SocieatyRestaurant restaurant) {
    setState(() {
      _selectedRestaurant = restaurant;
    });

    // Show the restaurant bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RestaurantBottomSheet(
        restaurant: restaurant,
        onViewDetailsPressed: () {
          context.push("/${restaurant.id}");
        },
        onDismissed: () {
          setState(() {
            _selectedRestaurant = null;
          });
        },
      ),
    );
  }

  void _updateMarkers() {
    final newMarkers = <Marker>{};

    // Add user location marker
    newMarkers.add(Marker(
      markerId: const MarkerId('user_location'),
      position: _userLocation,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: const InfoWindow(title: 'Your Location'),
    ));

    // Add restaurant markers
    for (var restaurant in _restaurants) {
      final markerId = MarkerId(restaurant.id);
      newMarkers.add(Marker(
        markerId: markerId,
        position: restaurant.restaurantData.location,
        infoWindow: InfoWindow(
          title: restaurant.name,
          snippet: '${restaurant.restaurantData.openTime} - ${restaurant.restaurantData.closeTime}',
        ),
        onTap: () {
          _onMarkerTapped(restaurant);
        },
      ));
    }

    setState(() {
      _markers.clear();
      _markers.addAll(newMarkers);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingRestaurants && _isFirstLoading) {
      return Scaffold(
        body: const CustomLoadingWidget(
          title: "Mencari restoran...",
          subtitle: "Mohon tunggu sebentar",
        ),
      );
    }

    if (_isError) {
      return CustomErrorWidget(
        error: "Gagal memuat daftar restoran",
        title: "Gagal memuat daftar restoran",
        onPressed: () {
          _fetchNearbyRestaurants();
        },
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              setState(() {
                _mapController = controller;
                controller.setMapStyle(_mapStyle);
              });
              _updateRadiusFromZoom();
              _updateCameraCenter();
            },
            onCameraMove: (position) {
              setState(() {
                _isMapIdle = false;
                _currentZoom = position.zoom;
              });
            },
            onCameraIdle: () async {
              if (_mapController != null && !_isMapIdle) {
                await _updateCameraCenter();
                _updateRadiusFromZoom();
                _debouncedFetchRestaurants();
              }

              setState(() {
                _isMapIdle = true;
              });
            },
            initialCameraPosition: CameraPosition(
              target: _userLocation,
              zoom: 15,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: _markers,
            mapType: MapType.terrain,
            compassEnabled: false,
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
          ),

          // Center point indicator
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 18,
            left: MediaQuery.of(context).size.width / 2 - 18,
            child: SizedBox(
              width: 36,
              height: 36,
              child: Icon(
                Icons.my_location,
                color: AppPallete.primaryColor,
                size: 28,
              ),
            ),
          ),

          // Close button
          Positioned(
            top: 20,
            left: 16,
            child: SafeArea(
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: AppPallete.primaryColor,
                  onPressed: () => context.pop(),
                ),
              ),
            ),
          ),

          // Radius indicator
          Positioned(
            top: 20,
            right: 16,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppPallete.neutralColor.shade300,
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  'Radius: ${(_searchRadius / 1000).toStringAsFixed(1)} km',
                  style: TextStyle(
                    color: AppPallete.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            right: 16,
            top: 150,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "btn_location",
                  backgroundColor: Colors.white,
                  onPressed: _animateToUserLocation,
                  mini: true,
                  child: Icon(
                    Icons.my_location,
                    color: AppPallete.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: "btn_refresh",
                  backgroundColor: Colors.white,
                  onPressed: _fetchNearbyRestaurants,
                  mini: true,
                  child: Icon(
                    Icons.refresh,
                    color: AppPallete.primaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Restaurant count chip (keeping this outside the bottom sheet)
          if (_restaurants.isNotEmpty && _selectedRestaurant == null)
            Positioned(
              bottom: 30,
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppPallete.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppPallete.neutralColor.shade300,
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Text(
                    'Ditemukan ${_restaurants.length} restoran',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
