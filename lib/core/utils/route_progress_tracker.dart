import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/route_utils.dart';

/// Class to track progress along a route and handle re-routing
class RouteProgressTracker {
  /// Default re-routing threshold in meters
  static const double defaultRerouteThreshold = 20.0;

  /// Check if a location is off-route (too far from any route point)
  static bool isOffRoute({
    required LatLng currentLocation,
    required List<LatLng> routePoints,
    double threshold = defaultRerouteThreshold,
  }) {
    if (routePoints.isEmpty) {
      return false;
    }

    double minDistance = double.infinity;

    for (final point in routePoints) {
      double distance = RouteUtils.calculateDistance(
        currentLocation.latitude,
        currentLocation.longitude,
        point.latitude,
        point.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
      }

      // If we found a point within threshold, user is not off-route
      if (minDistance <= threshold) {
        return false;
      }
    }

    // If the closest point is still further than threshold, user is off-route
    return minDistance > threshold;
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
    if (newClosestPointIndex <= lastPassedPointIndex) {
      return currentPassedPoints;
    }

    final List<bool> updatedPoints = List.from(currentPassedPoints);

    // Mark all points up to and including the closest one as passed
    for (int i = lastPassedPointIndex + 1; i <= newClosestPointIndex; i++) {
      updatedPoints[i] = true;
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

    final List<Polyline> polylines = [];
    final List<List<LatLng>> segments = [];
    final List<bool> segmentPassed = [];

    bool currentSegmentPassed = passedPoints[0];
    List<LatLng> currentSegment = [routePoints[0]];

    // Split the route into segments based on passed status
    for (int i = 1; i < routePoints.length; i++) {
      if (passedPoints[i] == currentSegmentPassed) {
        // Continue current segment
        currentSegment.add(routePoints[i]);
      } else {
        // End previous segment and start new one
        segments.add(currentSegment);
        segmentPassed.add(currentSegmentPassed);

        currentSegmentPassed = passedPoints[i];
        currentSegment = [routePoints[i - 1], routePoints[i]]; // Overlap to avoid gaps
      }
    }

    // Add the last segment
    if (currentSegment.isNotEmpty) {
      segments.add(currentSegment);
      segmentPassed.add(currentSegmentPassed);
    }

    // Create polylines for each segment with different colors
    for (int i = 0; i < segments.length; i++) {
      polylines.add(
        Polyline(
          polylineId: PolylineId('route_segment_$i'),
          points: segments[i],
          color: segmentPassed[i] ? Colors.grey : AppPallete.primaryColor,
          width: 5,
        ),
      );
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
