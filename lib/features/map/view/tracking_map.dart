import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/location_handler.dart';
import 'package:socieaty/core/utils/map_camera_utils.dart';
import 'package:socieaty/core/utils/map_markers_helper.dart';
import 'package:socieaty/features/map/view/map_test_screen.dart';
import 'package:go_router/go_router.dart' as go;
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';
import 'package:socieaty/core/utils/route_progress_tracker.dart';

class TrackingMapArgs {
  final LatLng customerLocation;
  final LatLng targetLocation;
  final String targetName;
  final String targetAddress;

  const TrackingMapArgs({
    required this.customerLocation,
    required this.targetLocation,
    required this.targetName,
    required this.targetAddress,
  });
}

class TrackingMap extends StatefulWidget {
  final TrackingMapArgs args;

  const TrackingMap({
    super.key,
    required this.args,
  });

  @override
  State<TrackingMap> createState() => _TrackingMapState();
}

class _TrackingMapState extends State<TrackingMap> {
  GoogleMapController? _mapController;
  final Location _locationService = Location();
  late LatLng _currentLocation;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoadingRoute = false;
  double _distance = 0;
  String _duration = '';
  StreamSubscription<LocationData>? _locationSubscription;
  RouteData? _routeData;

  // Re-routing settings
  bool _isRerouting = false;
  DateTime? _lastRerouteTime;

  // API call control
  static const int minimumRerouteIntervalSeconds = 5; // Minimum time between API calls

  // Progress tracking
  int _lastPassedPointIndex = -1;

  // Set to true to enable real-time location updates
  final bool _useRealTimeLocation = true;

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.args.customerLocation;
    _setupRouteAndMarkers();

    // Only start location updates if we're using real-time location
    if (_useRealTimeLocation) {
      _startLocationUpdates();
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _locationSubscription?.cancel();
    super.dispose();
  }

  void _startLocationUpdates() {
    try {
      _locationService.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 3000,
        distanceFilter: 5,
      );

      _locationSubscription =
          _locationService.onLocationChanged.listen((LocationData locationData) {
        if (mounted && locationData.latitude != null && locationData.longitude != null) {
          setState(() {
            _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
            _updateCurrentLocationMarker();

            // Update route progress (doesn't make API calls)
            _updateRouteProgress();

             // Check if rerouting is needed (but only if not already rerouting)
            if (!_isRerouting) {
              _checkAndHandleRerouting();
            }
          });
        }
      });
    } catch (e) {
      debugPrint("Error starting location updates: $e");
    }
  }

  // Check if rerouting is needed and handle it
  void _checkAndHandleRerouting() {
    // Skip if not enabled or no route data
    if (!_useRealTimeLocation || _routeData == null) {
      return;
    }

    // Enforce minimum time between API calls
    final now = DateTime.now();
    if (_lastRerouteTime != null) {
      final timeSinceLastReroute = now.difference(_lastRerouteTime!);
      if (timeSinceLastReroute.inSeconds < minimumRerouteIntervalSeconds) {
        return;
      }
    }

    // Check if user is off route
    if (RouteProgressTracker.isOffRoute(
      currentLocation: _currentLocation,
      routePoints: _routeData!.points,
    )) {
      debugPrint("Rerouting: User is off route. Calling API...");
      _lastRerouteTime = now;
      _isRerouting = true; // Set flag to prevent multiple simultaneous reroutings

      // Get a new route from current location to destination
      _setupRoute(forceReroute: true).then((_) {
        // Only reset the flag when the API call is complete
        if (mounted) {
          setState(() {
            _isRerouting = false;
          });
        }
      }).catchError((error) {
        // Make sure to reset the flag even if there's an error
        if (mounted) {
          setState(() {
            _isRerouting = false;
          });
        }
        debugPrint("Error during rerouting: $error");
      });
    }
  }

  // Update the route progress based on current location
  void _updateRouteProgress() {
    if (_routeData == null || _routeData!.points.isEmpty) {
      return;
    }

    // Find the closest point index
    final closestPointIndex = RouteProgressTracker.findClosestPointIndex(
      _currentLocation,
      _routeData!.points,
    );

    if (closestPointIndex > _lastPassedPointIndex) {
      // We've made progress along the route
      final updatedPassedPoints = RouteProgressTracker.updatePassedPoints(
        _routeData!.passedPoints,
        _lastPassedPointIndex,
        closestPointIndex,
      );

      _lastPassedPointIndex = closestPointIndex;

      // Update route data with new progress
      setState(() {
        _routeData = _routeData!.copyWith(passedPoints: updatedPassedPoints);
        _updateRouteDisplay();
      });
    }
  }

  // Update the display of the route based on passed points
  void _updateRouteDisplay() {
    if (_routeData == null || _routeData!.points.isEmpty) {
      return;
    }

    setState(() {
      _polylines = RouteProgressTracker.createRouteSegments(
        _routeData!.points,
        _routeData!.passedPoints,
      ).toSet();
    });
  }

  void _updateCurrentLocationMarker() {
    setState(() {
      _markers = MapMarkersHelper.updateCurrentLocationMarker(
        _markers,
        _currentLocation,
      );
    });
  }

  void _setupRouteAndMarkers() {
    // Initialize markers for origin and destination
    setState(() {
      _markers = LocationHandler.createRouteMarkers(
        origin: _currentLocation,
        destination: widget.args.targetLocation,
        destinationTitle: widget.args.targetName,
        destinationSnippet: widget.args.targetAddress,
      );
    });

    _setupRoute();
  }

  Future<void> _setupRoute({bool forceReroute = false}) async {
    setState(() {
      _isLoadingRoute = true;
    });

    try {
      // Use the new helper method with fallback
      final routeData = await LocationHandler.getRouteCoordinatesWithFallback(
        _currentLocation,
        widget.args.targetLocation,
      );

      if (mounted) {
        setState(() {
          _routeData = routeData;
          _lastPassedPointIndex = -1; // Reset progress tracking
          _distance = routeData.distance;
          _duration = routeData.duration;
          _isLoadingRoute = false;
          _updateRouteDisplay();
        });

        // Only fit to the entire route if this isn't a reroute.
        // During rerouting, keep camera on current location
        if (!forceReroute) {
          _fitMapToRoute();
        } else {
          _centerOnCurrentLocation();
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingRoute = false;
      });
    }
  }

  void _fitMapToRoute() {
    if (_mapController == null || _routeData == null || _routeData!.points.isEmpty) {
      return;
    }

    try {
      final cameraUpdate = MapCameraUtils.fitToPointsList(_routeData!.points);
      _mapController!.animateCamera(cameraUpdate);
    } catch (e) {
      // Fallback to simple two-point bounds
      final fallbackUpdate =
          MapCameraUtils.fitToPoints(_currentLocation, widget.args.targetLocation);
      _mapController!.animateCamera(fallbackUpdate);
    }
  }

  void _centerOnCurrentLocation() {
    if (_mapController == null) return;

    final cameraUpdate = MapCameraUtils.centerOnLocation(_currentLocation);
    _mapController!.animateCamera(cameraUpdate);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              setState(() {
                _mapController = controller;
                _fitMapToRoute();
              });
            },
            myLocationEnabled: _useRealTimeLocation,
            myLocationButtonEnabled: false,
            markers: _markers,
            polylines: _polylines,
            mapType: MapType.normal,
          ),
          if (_isRerouting)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(180),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: LoadingIndicatorWidget(size: 20, color: Colors.white),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Menghitung ulang rute...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            top: 50,
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

          // Test Button to launch simulation
          Positioned(
            top: 50,
            right: 16,
            child: SafeArea(
              child: CircleAvatar(
                backgroundColor: Colors.blue,
                child: IconButton(
                  icon: const Icon(Icons.science, color: Colors.white),
                  tooltip: 'Open Test Simulation',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MapTestScreen(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          Positioned(
            right: 16,
            bottom: 220,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "btn1",
                  backgroundColor: Colors.white,
                  onPressed: _centerOnCurrentLocation,
                  mini: true,
                  child: Icon(
                    Icons.my_location,
                    color: AppPallete.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: "btn2",
                  backgroundColor: Colors.white,
                  onPressed: _fitMapToRoute,
                  mini: true,
                  child: Icon(
                    Icons.route,
                    color: AppPallete.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: "btn3",
                  backgroundColor: Colors.white,
                  onPressed: () => _setupRoute(forceReroute: true),
                  mini: true,
                  child: Icon(
                    Icons.refresh,
                    color: AppPallete.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            width: screenWidth,
            child: Container(
              padding: const EdgeInsets.all(24.0),
              width: screenWidth,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30.0)),
                color: AppPallete.neutralColor.shade50,
                boxShadow: [
                  BoxShadow(
                    color: AppPallete.neutralColor.shade300,
                    spreadRadius: 2,
                    blurRadius: 7,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Informasi Rute",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      _isLoadingRoute
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: LoadingIndicatorWidget(size: 20),
                            )
                          : const SizedBox(),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppPallete.primaryColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.directions_car,
                              size: 16,
                              color: AppPallete.primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _distance > 0
                                  ? "${(_distance / 1000).toStringAsFixed(1)} km"
                                  : "Menghitung...",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppPallete.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppPallete.primaryColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: AppPallete.primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _duration.isNotEmpty ? _duration : "Menghitung...",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppPallete.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppPallete.primaryColor,
                        size: 35.0,
                      ),
                      const SizedBox(width: 16.0),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.args.targetName,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              widget.args.targetAddress,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
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
