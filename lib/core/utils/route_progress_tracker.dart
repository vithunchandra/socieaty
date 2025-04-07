import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/route_utils.dart';

/// Class to track progress along a route and handle re-routing
class RouteProgressTracker {
  /// Default re-routing threshold in meters
  static const double defaultRerouteThreshold = 50.0;

  /// Check if a location is off-route (too far from any route point)
  static bool isOffRoute({
    required LatLng currentLocation,
    required List<LatLng> routePoints,
    double threshold = defaultRerouteThreshold,
  }) {
    if (routePoints.isEmpty) {
      return false;
    }
    debugPrint("==========================");
    debugPrint("Route Points: $routePoints");
    for (final point in routePoints) {
      double distance = RouteUtils.calculateDistance(
        currentLocation.latitude,
        currentLocation.longitude,
        point.latitude,
        point.longitude,
      );

      // debugPrint("Distance: $distance, threshold: $threshold");
      // If we found a point within threshold, user is not off-route
      if (distance <= threshold) {
        return false;
      }
    }

    // If the closest point is still further than threshold, user is off-route
    return true;
  }

  /// Find the index of the closest point on the route to the current location
  static int findClosestPointIndex(LatLng currentLocation, List<LatLng> routePoints) {
    if (routePoints.isEmpty) {
      return -1;
    }

    int closestIndex = 0;
    double minDistance = RouteUtils.calculateDistance(
      currentLocation.latitude,
      currentLocation.longitude,
      routePoints[0].latitude,
      routePoints[0].longitude,
    );

    for (int i = 1; i < routePoints.length; i++) {
      double distance = RouteUtils.calculateDistance(
        currentLocation.latitude,
        currentLocation.longitude,
        routePoints[i].latitude,
        routePoints[i].longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    return closestIndex;
  }

  /// Update which points on the route have been passed
  static List<bool> updatePassedPoints(
    List<bool> currentPassedPoints,
    int lastPassedPointIndex,
    int newClosestPointIndex,
  ) {
    final List<bool> updatedPoints = List.from(currentPassedPoints);

    if (newClosestPointIndex > lastPassedPointIndex) {
      // Moving forward - Mark all points up to and including the closest one as passed
      for (int i = lastPassedPointIndex + 1; i <= newClosestPointIndex; i++) {
        updatedPoints[i] = true;
      }
    } else if (newClosestPointIndex < lastPassedPointIndex) {
      // Moving backward - Mark all points after the closest one as not passed
      for (int i = newClosestPointIndex + 1; i <= lastPassedPointIndex; i++) {
        updatedPoints[i] = false;
      }
    }

    return updatedPoints;
  }

  /// Split a route into segments based on passed status for visualization
  static List<Polyline> createRouteSegments(
    List<LatLng> routePoints,
    List<bool> passedPoints,
  ) {
    if (routePoints.isEmpty || passedPoints.isEmpty || routePoints.length != passedPoints.length) {
      return [];
    }

    // Find the transition index (last passed point)
    int transitionIndex = -1;
    for (int i = 0; i < passedPoints.length; i++) {
      if (passedPoints[i]) {
        transitionIndex = i;
      }
    }

    final List<Polyline> polylines = [];

    // Create passed segment (gray) - only if we have passed points
    if (transitionIndex >= 0) {
      List<LatLng> passedSegment = routePoints.sublist(0, transitionIndex + 1);

      if (passedSegment.length > 1) {
        polylines.add(
          Polyline(
            polylineId: const PolylineId('passed_segment'),
            points: passedSegment,
            color: Colors.grey,
            width: 5,
          ),
        );
      }
    }

    // Create not-passed segment (primary color) - only if we have points ahead
    if (transitionIndex < routePoints.length - 1) {
      List<LatLng> notPassedSegment = [];

      // Add the transition point to ensure continuity if it exists
      if (transitionIndex >= 0) {
        notPassedSegment.add(routePoints[transitionIndex]);
      }

      // Add all remaining points
      notPassedSegment.addAll(routePoints.sublist(transitionIndex + 1));

      if (notPassedSegment.length > 1) {
        polylines.add(
          Polyline(
            polylineId: const PolylineId('not_passed_segment'),
            points: notPassedSegment,
            color: AppPallete.primaryColor,
            width: 5,
          ),
        );
      }
    }

    return polylines;
  }

  /// Calculate the percentage of route completed based on passed points
  static double calculateRouteCompletionPercentage(List<bool> passedPoints) {
    if (passedPoints.isEmpty) return 0.0;

    int passedCount = passedPoints.where((passed) => passed).length;
    return passedCount / passedPoints.length;
  }
}
