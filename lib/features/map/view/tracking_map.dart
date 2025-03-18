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

class TrackingMap extends StatefulWidget {
  final LatLng customerLocation;
  final LatLng targetLocation;
  final String targetName;
  final String targetAddress;

  const TrackingMap({
    super.key,
    required this.customerLocation,
    required this.targetLocation,
    required this.targetName,
    required this.targetAddress,
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

  // Progress tracking
  int _lastPassedPointIndex = -1;

  // Set to true to enable real-time location updates
  final bool _useRealTimeLocation = false;

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.customerLocation;
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
        interval: 5000,
        distanceFilter: 5,
      );

      _locationSubscription =
          _locationService.onLocationChanged.listen((LocationData locationData) {
        if (mounted && locationData.latitude != null && locationData.longitude != null) {
          setState(() {
            _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
            _updateCurrentLocationMarker();

            // Check if the user is off-route and needs re-routing
            _checkAndHandleRerouting();

            // Update route progress
            _updateRouteProgress();
          });
        }
      });
    } catch (e) {
      debugPrint("Error starting location updates: $e");
    }
  }

  // Check if rerouting is needed and handle it
  void _checkAndHandleRerouting() {
    // Skip if already rerouting or not enabled
    if (_isRerouting || !_useRealTimeLocation || _routeData == null) {
      return;
    }

    // Avoid too frequent rerouting (minimum 30 seconds between reroutes)
    final now = DateTime.now();
    if (_lastRerouteTime != null) {
      final timeSinceLastReroute = now.difference(_lastRerouteTime!);
      if (timeSinceLastReroute.inSeconds < 30) {
        return;
      }
    }

    // Check if user is off route using the utility class
    if (LocationHandler.needsRerouting(_currentLocation, _routeData!.points)) {
      debugPrint("User is off route. Initiating rerouting...");
      _lastRerouteTime = now;
      _isRerouting = true;

      // Get a new route from current location to destination
      _setupRoute(forceReroute: true).then((_) {
        _isRerouting = false;
      });
    }
  }

  // Update the route progress based on current location
  void _updateRouteProgress() {
    if (_routeData == null || _routeData!.points.isEmpty) {
      return;
    }

    // Use LocationHandler utility to update progress
    final updatedRouteData = LocationHandler.updateRouteProgress(
      _routeData!,
      _currentLocation,
      _lastPassedPointIndex,
    );

    // If we've made progress, update state
    if (updatedRouteData != _routeData) {
      setState(() {
        _routeData = updatedRouteData;
        // Find the new last passed point index
        _lastPassedPointIndex = updatedRouteData.passedPoints.lastIndexWhere((passed) => passed);
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
      _polylines = LocationHandler.createRoutePolylines(_routeData!);
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
        destination: widget.targetLocation,
        destinationTitle: widget.targetName,
        destinationSnippet: widget.targetAddress,
      );
    });

    _setupRoute();
  }

  Future<void> _setupRoute({bool forceReroute = false}) async {
    setState(() {
      _isLoadingRoute = true;
    });

    try {
      debugPrint(
          "Requesting route from: ${_currentLocation.latitude},${_currentLocation.longitude} to ${widget.targetLocation.latitude},${widget.targetLocation.longitude}");

      // Use the new helper method with fallback
      final routeData = await LocationHandler.getRouteCoordinatesWithFallback(
        _currentLocation,
        widget.targetLocation,
      );

      if (mounted) {
        debugPrint("Route data received: ${routeData.distance} meters, ${routeData.duration}");

        setState(() {
          _routeData = routeData;
          _lastPassedPointIndex = -1; // Reset progress tracking
          _distance = routeData.distance;
          _duration = routeData.duration;
          _isLoadingRoute = false;
          _updateRouteDisplay();
        });

        _fitMapToRoute();
      }
    } catch (e) {
      debugPrint("Error in _setupRoute: $e");
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
      debugPrint("Error fitting map to route: $e");

      // Fallback to simple two-point bounds
      final fallbackUpdate = MapCameraUtils.fitToPoints(_currentLocation, widget.targetLocation);
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
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
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
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                              ),
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
                              widget.targetName,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              widget.targetAddress,
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
