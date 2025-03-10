import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/location_handler.dart';
import 'package:socieaty/core/utils/map_camera_utils.dart';
import 'package:socieaty/core/utils/map_markers_helper.dart';
import 'package:socieaty/core/utils/route_progress_tracker.dart';
import 'package:socieaty/core/utils/route_utils.dart';

class TrackingMapSimulation extends StatefulWidget {
  final LatLng startLocation;
  final LatLng targetLocation;
  final String targetName;

  const TrackingMapSimulation({
    super.key,
    required this.startLocation,
    required this.targetLocation,
    required this.targetName,
  });

  @override
  State<TrackingMapSimulation> createState() => _TrackingMapSimulationState();
}

class _TrackingMapSimulationState extends State<TrackingMapSimulation> {
  GoogleMapController? _mapController;
  late LatLng _currentLocation;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoadingRoute = false;
  bool _isRerouting = false;
  bool _showDebugInfo = true;
  double _distance = 0;
  String _duration = '';
  RouteData? _routeData;
  int _lastPassedPointIndex = -1;

  // Simulation control variables
  List<LatLng> _simulationPoints = [];
  int _currentSimulationPoint = 0;
  bool _isSimulationRunning = false;
  Timer? _simulationTimer;
  bool _isFollowingRoute = true;
  double _deviationAmount = 0.0002; // Roughly 20-30 meters
  final List<String> _simulationLogs = [];

  // API tracking variables
  int _totalApiCalls = 0;
  int _successfulApiCalls = 0;
  int _failedApiCalls = 0;
  double _avgApiResponseTime = 0;
  final List<double> _apiResponseTimes = [];
  DateTime? _lastApiCallTime;

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.startLocation;
    _setupRouteAndMarkers();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _simulationTimer?.cancel();
    super.dispose();
  }

  void _setupRouteAndMarkers() {
    // Initialize markers for origin and destination
    setState(() {
      _markers = LocationHandler.createRouteMarkers(
        origin: _currentLocation,
        destination: widget.targetLocation,
        destinationTitle: widget.targetName,
        originDraggable: true,
        onOriginDragEnd: (newPosition) {
          setState(() {
            _currentLocation = newPosition;
            _checkAndHandleRerouting();
            _updateRouteProgress();
          });
        },
      );
    });

    _setupRoute();
  }

  void _updateCurrentLocationMarker() {
    setState(() {
      _markers = MapMarkersHelper.updateCurrentLocationMarker(
        _markers,
        _currentLocation,
        draggable: true,
        onDragEnd: (newPosition) {
          setState(() {
            _currentLocation = newPosition;
            _checkAndHandleRerouting();
            _updateRouteProgress();
          });
        },
      );
    });
  }

  Future<void> _setupRoute({bool forceReroute = false}) async {
    setState(() {
      _isLoadingRoute = true;
    });

    // Record API call start time
    _lastApiCallTime = DateTime.now();
    _totalApiCalls++;

    try {
      _addSimulationLog(
          "API CALL: Route from: ${_currentLocation.latitude}, ${_currentLocation.longitude} to ${widget.targetLocation.latitude}, ${widget.targetLocation.longitude}");

      final routeData = await LocationHandler.getRouteCoordinates(
        _currentLocation,
        widget.targetLocation,
      );

      // Calculate API response time
      final responseTime = DateTime.now().difference(_lastApiCallTime!).inMilliseconds / 1000;
      _apiResponseTimes.add(responseTime);
      _avgApiResponseTime = _apiResponseTimes.reduce((a, b) => a + b) / _apiResponseTimes.length;

      if (routeData != null && mounted) {
        _successfulApiCalls++;
        _addSimulationLog(
            "✅ API SUCCESS (${responseTime.toStringAsFixed(2)}s): ${routeData.points.length} points, ${routeData.distance}m, ${routeData.duration}");

        if (routeData.points.isEmpty) {
          _addSimulationLog("⚠️ Warning: Empty points list received");
          _useDefaultRouteDisplay();
          return;
        }

        setState(() {
          _routeData = routeData;
          _lastPassedPointIndex = -1; // Reset progress tracking
          _distance = routeData.distance;
          _duration = routeData.duration;
          _isLoadingRoute = false;
          _updateRouteDisplay();

          // Reset simulation points when a new route is calculated
          _setupSimulationPoints(routeData.points);
        });

        _fitMapToRoute();
      } else {
        _failedApiCalls++;
        _addSimulationLog("❌ API FAILED (${responseTime.toStringAsFixed(2)}s): No route data");
        _useDefaultRouteDisplay();
      }
    } catch (e) {
      _failedApiCalls++;
      final responseTime = DateTime.now().difference(_lastApiCallTime!).inMilliseconds / 1000;
      _addSimulationLog("❌ API ERROR (${responseTime.toStringAsFixed(2)}s): $e");
      _useDefaultRouteDisplay();
    }
  }

  void _useDefaultRouteDisplay() {
    // Calculate straight-line distance as fallback
    final double fallbackDistanceInMeters =
        RouteUtils.calculateStraightLineDistance(_currentLocation, widget.targetLocation);

    // Create a simple straight line for visualization
    final List<LatLng> straightLine =
        RouteUtils.createStraightLine(_currentLocation, widget.targetLocation);

    setState(() {
      _routeData = RouteData(
        points: straightLine,
        distance: fallbackDistanceInMeters,
        duration: RouteUtils.estimateDuration(fallbackDistanceInMeters),
      );
      _distance = fallbackDistanceInMeters;
      _duration = RouteUtils.estimateDuration(fallbackDistanceInMeters);
      _isLoadingRoute = false;
      _updateRouteDisplay();

      // Setup simulation points with straight line
      _setupSimulationPoints(straightLine);
    });

    _fitMapToRoute();
  }

  // Set up points for simulation along the route
  void _setupSimulationPoints(List<LatLng> routePoints) {
    if (routePoints.isEmpty) return;

    _simulationPoints = List.from(routePoints);
    _currentSimulationPoint = 0;
    _addSimulationLog("Simulation ready with ${_simulationPoints.length} points");
  }

  // Start the simulation to move along the route
  void _startSimulation() {
    if (_simulationPoints.isEmpty || _isSimulationRunning) return;

    _isSimulationRunning = true;
    _addSimulationLog("Starting simulation...");

    _simulationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentSimulationPoint >= _simulationPoints.length - 1) {
        _stopSimulation();
        _addSimulationLog("Reached destination! Simulation complete.");
        return;
      }

      // Move to next point
      _currentSimulationPoint++;

      // Get the next point, potentially with deviation
      LatLng nextPoint = _getNextSimulationPoint();

      setState(() {
        _currentLocation = nextPoint;
        _updateCurrentLocationMarker();
        _updateRouteProgress();

        // Check if re-routing is needed
        _checkAndHandleRerouting();
      });
    });
  }

  // Get the next point, potentially with deviation based on settings
  LatLng _getNextSimulationPoint() {
    if (_currentSimulationPoint >= _simulationPoints.length) {
      return _simulationPoints.last;
    }

    LatLng basePoint = _simulationPoints[_currentSimulationPoint];

    // If we're following the route, return the exact point
    if (_isFollowingRoute) {
      return basePoint;
    }

    // Otherwise, add some deviation
    // Use random deviation to simulate going off-route
    Random random = Random();
    double latDeviation = (random.nextDouble() * 2 - 1) * _deviationAmount;
    double lngDeviation = (random.nextDouble() * 2 - 1) * _deviationAmount;

    return LatLng(
      basePoint.latitude + latDeviation,
      basePoint.longitude + lngDeviation,
    );
  }

  // Stop the simulation
  void _stopSimulation() {
    _simulationTimer?.cancel();
    _isSimulationRunning = false;
    _addSimulationLog("Simulation stopped");
  }

  // Check if user is off route and needs rerouting
  void _checkAndHandleRerouting() {
    if (_isRerouting || _routeData == null) return;

    // Check if user is off route
    if (RouteProgressTracker.isOffRoute(
      currentLocation: _currentLocation,
      routePoints: _routeData!.points,
    )) {
      _addSimulationLog(
          "⚠️ User is off route! Distance > ${RouteProgressTracker.defaultRerouteThreshold} meters. Re-routing...");
      _isRerouting = true;

      // Reset simulation
      _stopSimulation();

      // Get a new route
      _setupRoute(forceReroute: true).then((_) {
        _isRerouting = false;
      });
    }
  }

  // Update route progress based on current location
  void _updateRouteProgress() {
    if (_routeData == null || _routeData!.points.isEmpty) {
      return;
    }

    // Find the closest point index
    final closestPointIndex =
        RouteProgressTracker.findClosestPointIndex(_currentLocation, _routeData!.points);

    if (closestPointIndex > _lastPassedPointIndex) {
      _addSimulationLog(
          "📍 Progressed to point $closestPointIndex/${_routeData!.points.length - 1}");

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

  // Update the display of the route based on passed segments
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

  void _toggleDeviation() {
    setState(() {
      _isFollowingRoute = !_isFollowingRoute;
      _addSimulationLog(_isFollowingRoute
          ? "Simulation will follow the route"
          : "Simulation will deviate from the route");
    });
  }

  void _addSimulationLog(String message) {
    if (_simulationLogs.length > 10) {
      _simulationLogs.removeAt(0);
    }

    setState(() {
      _simulationLogs.add(message);
    });
  }

  String _getApiSummary() {
    final successRate =
        _totalApiCalls > 0 ? (_successfulApiCalls / _totalApiCalls * 100).toStringAsFixed(0) : '0';

    return 'API Calls: $_totalApiCalls | Success: $_successfulApiCalls | Failed: $_failedApiCalls | '
        'Success Rate: $successRate% | Avg Time: ${_avgApiResponseTime.toStringAsFixed(2)}s';
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App Bar replacement
            Container(
              height: 56,
              color: AppPallete.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Route Simulation',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // API Summary Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(100),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.api, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "API: $_totalApiCalls",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(_showDebugInfo ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _showDebugInfo = !_showDebugInfo;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Map Container - uses Expanded to take all remaining space
            Expanded(
              child: Stack(
                children: [
                  // Google Map
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
                    markers: _markers,
                    polylines: _polylines,
                    mapType: MapType.normal,
                  ),

                  // Rerouting indicator
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
                              'Recalculating route...',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Map control buttons
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingActionButton(
                          heroTag: "center_location",
                          backgroundColor: Colors.white,
                          onPressed: _centerOnCurrentLocation,
                          mini: true,
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FloatingActionButton(
                          heroTag: "fit_route",
                          backgroundColor: Colors.white,
                          onPressed: _fitMapToRoute,
                          mini: true,
                          child: const Icon(
                            Icons.route,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FloatingActionButton(
                          heroTag: "refresh_route",
                          backgroundColor: Colors.white,
                          onPressed: () => _setupRoute(forceReroute: true),
                          mini: true,
                          child: const Icon(
                            Icons.refresh,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Debug info panel - show only when enabled
                  if (_showDebugInfo)
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(160),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withAlpha(30), width: 1),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // API Stats row
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withAlpha(50),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _getApiSummary(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Log entries
                            const Text(
                              'SIMULATION LOGS:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Only show last 5 logs to save space
                            ...(_simulationLogs.length > 5
                                    ? _simulationLogs.sublist(_simulationLogs.length - 5)
                                    : _simulationLogs)
                                .reversed
                                .map(
                                  (log) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      log,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontFamily: 'monospace',
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Bottom Control Panel - sized to fit content
            Container(
              width: screenWidth,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Route Info - made more compact
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Distance & Duration - more compact layout
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.route, size: 14, color: Colors.blue),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Distance: ${_distance > 0 ? "${(_distance / 1000).toStringAsFixed(1)} km" : "..."}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.timer, size: 14, color: Colors.orange),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Duration: ${_duration.isNotEmpty ? _duration : "..."}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Loading indicator
                        if (_isLoadingRoute)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2.0),
                          ),
                      ],
                    ),

                    const Divider(height: 12),

                    // Simulation Controls - combined in a single row for compactness
                    Row(
                      children: [
                        // Start/Stop button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isSimulationRunning ? _stopSimulation : _startSimulation,
                            icon: Icon(_isSimulationRunning ? Icons.stop : Icons.play_arrow,
                                size: 14),
                            label: Text(
                              _isSimulationRunning ? 'Stop' : 'Start',
                              style: const TextStyle(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isSimulationRunning ? Colors.red : Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              minimumSize: const Size(0, 32),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Follow/Deviate button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _toggleDeviation,
                            icon: Icon(
                              _isFollowingRoute ? Icons.straight : Icons.wrong_location,
                              size: 14,
                            ),
                            label: Text(
                              _isFollowingRoute ? 'Follow' : 'Deviate',
                              style: const TextStyle(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isFollowingRoute ? Colors.blue : Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              minimumSize: const Size(0, 32),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Status and deviation controls
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          // Deviation slider in compact form
                          const Text('Deviation:', style: TextStyle(fontSize: 11)),
                          const SizedBox(width: 4),

                          // Slider
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 2.0,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5.0),
                                overlayShape: const RoundSliderOverlayShape(overlayRadius: 8.0),
                              ),
                              child: Slider(
                                value: _deviationAmount,
                                min: 0.0001,
                                max: 0.001,
                                divisions: 9,
                                activeColor: Colors.orange,
                                onChanged: (value) {
                                  setState(() {
                                    _deviationAmount = value;
                                  });
                                },
                              ),
                            ),
                          ),

                          // Value display
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              "${(_deviationAmount * 100000).toStringAsFixed(0)}m",
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),

                          // Simulation status
                          if (_isSimulationRunning)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withAlpha(20),
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(color: Colors.blue.withAlpha(60), width: 1),
                                ),
                                child: Text(
                                  '$_currentSimulationPoint/${_simulationPoints.length}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.blue.shade800,
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
            ),
          ],
        ),
      ),
    );
  }
}
