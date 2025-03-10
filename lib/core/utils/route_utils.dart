import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Utility class for route-related calculations and functions
class RouteUtils {
  /// Calculate distance between two coordinates using Haversine formula (in meters)
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // in meters

    // Convert degrees to radians
    final double lat1Rad = lat1 * (pi / 180);
    final double lon1Rad = lon1 * (pi / 180);
    final double lat2Rad = lat2 * (pi / 180);
    final double lon2Rad = lon2 * (pi / 180);

    // Haversine formula
    final double dLat = lat2Rad - lat1Rad;
    final double dLon = lon2Rad - lon1Rad;

    final double a =
        sin(dLat / 2) * sin(dLat / 2) + cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// Calculate straight-line distance between two LatLng points
  static double calculateStraightLineDistance(LatLng origin, LatLng destination) {
    return calculateDistance(
        origin.latitude, origin.longitude, destination.latitude, destination.longitude);
  }

  /// Create a straight line between two points (helpful as fallback when API fails)
  static List<LatLng> createStraightLine(LatLng origin, LatLng destination) {
    return [origin, destination];
  }

  /// Estimate travel duration based on distance (in meters)
  /// Returns a formatted string like "X mins"
  static String estimateDuration(double distanceInMeters, {double speedMetersPerMinute = 400}) {
    final minutes = (distanceInMeters / speedMetersPerMinute).round();
    return "$minutes mins";
  }

  /// Create a LatLngBounds that includes two points
  static LatLngBounds createBoundsFromPoints(LatLng point1, LatLng point2) {
    return LatLngBounds(
      southwest: LatLng(
        min(point1.latitude, point2.latitude),
        min(point1.longitude, point2.longitude),
      ),
      northeast: LatLng(
        max(point1.latitude, point2.latitude),
        max(point1.longitude, point2.longitude),
      ),
    );
  }

  /// Create a LatLngBounds that includes all points in a list
  static LatLngBounds createBoundsFromPointsList(List<LatLng> points) {
    if (points.isEmpty) {
      throw ArgumentError('Points list cannot be empty');
    }

    double minLat = points[0].latitude;
    double maxLat = points[0].latitude;
    double minLng = points[0].longitude;
    double maxLng = points[0].longitude;

    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}
