import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:socieaty/env.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter/material.dart';
import 'package:socieaty/core/utils/route_utils.dart';
import 'package:socieaty/core/utils/map_markers_helper.dart';
import 'package:socieaty/core/utils/route_progress_tracker.dart';

class RouteData {
  final List<LatLng> points;
  final double distance;
  final String duration;
  final List<bool> passedPoints; // Track which points have been passed by the user

  RouteData({
    required this.points,
    required this.distance,
    required this.duration,
    List<bool>? passedPoints,
  }) : passedPoints = passedPoints ?? List.filled(points.length, false);

  // Create a copy of RouteData with updated passed points
  RouteData copyWith({List<bool>? passedPoints}) {
    return RouteData(
      points: points,
      distance: distance,
      duration: duration,
      passedPoints: passedPoints ?? this.passedPoints,
    );
  }
}

abstract class LocationHandler {
  static Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    PermissionStatus permission;

    serviceEnabled = await Location.instance.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await Location.instance.requestService();
      if (!serviceEnabled) return false;
    }

    permission = await Location.instance.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await Location.instance.requestPermission();
      if (permission != PermissionStatus.granted) return false;
    }

    if (permission == PermissionStatus.deniedForever) return false;

    return true;
  }

  static Future<LocationData?> getCurrentPosition() async {
    try {
      final hasPermission = await handleLocationPermission();
      if (!hasPermission) return null;
      Location.instance.changeSettings(accuracy: LocationAccuracy.high);
      return await Location.instance.getLocation();
    } catch (e) {
      return null;
    }
  }

  static Future<dynamic> getAutoComplete(
      String query, String token, CancelToken cancelToken) async {
    try {
      String basedUrl = "https://maps.googleapis.com/maps/api/place/autocomplete/json";
      final response = await Dio().get(
        basedUrl,
        queryParameters: {
          "input": query,
          "sessiontoken": token,
          "key": Env.googleApiKey,
          "components": "country:id",
          "region": "id",
          "radius": 150,
        },
        cancelToken: cancelToken,
      );
      if (response.statusCode != 200) {
        throw Exception("Failed to load");
      }
      final data = response.data['predictions'];
      return data;
    } catch (err) {
      return [];
    }
  }

  static Future<dynamic> getNearbyPlace(LatLng location) async {
    String basedUrl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json";
    final response = await Dio().get(basedUrl, queryParameters: {
      "location": "${location.latitude}%2C${location.longitude}",
      "radius": 100,
      "key": Env.googleApiKey,
    });
    if (response.statusCode != 200) {
      throw Exception("Something went wrong");
    }
    final data = response.data['results'][0];
    return data;
  }

  static Future<geocoding.Placemark?> getAddressFromLatLng(LatLng location) async {
    try {
      var rawAddress = await geocoding.GeocodingPlatform.instance
          ?.placemarkFromCoordinates(location.latitude, location.longitude);
      return rawAddress?[0];
    } catch (error) {
      return null;
    }
  }

  static Future getPlaceDetails(String placeId) async {
    final baseUrl = "https://maps.googleapis.com/maps/api/place/details/json";
    final response = await Dio().get(baseUrl, queryParameters: {
      "place_id": placeId,
      "fields": "formatted_address,name,geometry",
      "key": Env.googleApiKey,
    });
    if (response.statusCode != 200) {
      throw Exception("Something went wrong");
    }
    return response.data['result'];
  }

  /// Get route coordinates between two points using Google Maps Directions API
  /// Returns a RouteData object with points, distance, and duration
  /// If API fails, will return null (caller should handle fallback)
  static Future<RouteData?> getRouteCoordinates(LatLng origin, LatLng destination) async {
    try {
      debugPrint(
          "Requesting directions from Google Maps API: origin=${origin.latitude},${origin.longitude}, destination=${destination.latitude},${destination.longitude}");

      // First try to use Dio to get full route details including distance and duration
      final String baseUrl = "https://maps.googleapis.com/maps/api/directions/json";
      final response = await Dio().get(
        baseUrl,
        queryParameters: {
          "origin": "${origin.latitude},${origin.longitude}",
          "destination": "${destination.latitude},${destination.longitude}",
          "mode": "driving",
          "key": Env.googleApiKey,
        },
      );

      debugPrint("Google Maps API response status: ${response.statusCode}");

      if (response.statusCode != 200) {
        debugPrint("Google Maps API error: HTTP ${response.statusCode}");
        return null;
      }

      if (response.data['status'] != 'OK') {
        debugPrint(
            "Google Maps API error: ${response.data['status']} - ${response.data['error_message'] ?? 'No error message'}");
        return null;
      }

      final routes = response.data['routes'];
      if (routes.isEmpty) {
        debugPrint("No routes found in the Google Maps API response");
        return null;
      }

      final legs = routes[0]['legs'];
      if (legs.isEmpty) {
        debugPrint("No legs found in the Google Maps API response");
        return null;
      }

      final distance = legs[0]['distance']['value'].toDouble();
      final duration = legs[0]['duration']['text'];

      // Use flutter_polyline_points to decode the polyline
      final polylinePoints = PolylinePoints();
      final polylineResult =
          polylinePoints.decodePolyline(routes[0]['overview_polyline']['points']);

      // Convert to LatLng for GoogleMap
      List<LatLng> polylineCoordinates =
          polylineResult.map((point) => LatLng(point.latitude, point.longitude)).toList();

      debugPrint("Decoded ${polylineCoordinates.length} points from polyline");
      debugPrint("Route data parsed: distance=${distance}m, duration=$duration");

      return RouteData(
        points: polylineCoordinates,
        distance: distance,
        duration: duration,
      );
    } catch (e) {
      debugPrint("Error getting route coordinates: $e");
      return null;
    }
  }

  /// Get route coordinates with fallback to straight line if API fails
  /// This is a utility method that will never return null
  static Future<RouteData> getRouteCoordinatesWithFallback(
      LatLng origin, LatLng destination) async {
    // Try to get route from API
    final RouteData? apiRouteData = await getRouteCoordinates(origin, destination);

    // If API route is valid, return it
    if (apiRouteData != null && apiRouteData.points.isNotEmpty) {
      return apiRouteData;
    }

    // Otherwise, create a fallback route using a straight line
    debugPrint("Using fallback straight line route");
    final double fallbackDistance = RouteUtils.calculateStraightLineDistance(origin, destination);
    final String fallbackDuration = RouteUtils.estimateDuration(fallbackDistance);

    return RouteData(
      points: RouteUtils.createStraightLine(origin, destination),
      distance: fallbackDistance,
      duration: fallbackDuration,
    );
  }

  /// Create a Set of Markers for origin and destination
  static Set<Marker> createRouteMarkers({
    required LatLng origin,
    required LatLng destination,
    required String destinationTitle,
    String? destinationSnippet,
    bool originDraggable = false,
    Function(LatLng)? onOriginDragEnd,
  }) {
    return {
      MapMarkersHelper.createCurrentLocationMarker(
        position: origin,
        draggable: originDraggable,
        onDragEnd: onOriginDragEnd,
      ),
      MapMarkersHelper.createDestinationMarker(
        position: destination,
        title: destinationTitle,
        snippet: destinationSnippet,
      ),
    };
  }

  /// Update route progress based on current location
  static RouteData updateRouteProgress(
    RouteData routeData,
    LatLng currentLocation,
    int lastPassedPointIndex,
  ) {
    if (routeData.points.isEmpty) return routeData;

    // Find closest point
    final closestPointIndex = RouteProgressTracker.findClosestPointIndex(
      currentLocation,
      routeData.points,
    );

    // If we haven't made progress, return original
    if (closestPointIndex <= lastPassedPointIndex) {
      return routeData;
    }

    // Update passed points
    final updatedPassedPoints = RouteProgressTracker.updatePassedPoints(
      routeData.passedPoints,
      lastPassedPointIndex,
      closestPointIndex,
    );

    // Return updated route data
    return routeData.copyWith(passedPoints: updatedPassedPoints);
  }

  /// Check if user is off route and needs re-routing
  static bool needsRerouting(LatLng currentLocation, List<LatLng> routePoints,
      {double threshold = RouteProgressTracker.defaultRerouteThreshold}) {
    return RouteProgressTracker.isOffRoute(
      currentLocation: currentLocation,
      routePoints: routePoints,
      threshold: threshold,
    );
  }

  /// Create polylines for visualizing route progress
  static Set<Polyline> createRoutePolylines(RouteData routeData) {
    return RouteProgressTracker.createRouteSegments(
      routeData.points,
      routeData.passedPoints,
    ).toSet();
  }
}
