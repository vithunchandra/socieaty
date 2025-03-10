import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socieaty/core/utils/route_utils.dart';

/// Utility class to handle Google Maps camera positioning and movement
class MapCameraUtils {
  /// Center the map camera on a specific location
  static CameraUpdate centerOnLocation(LatLng location, {double zoom = 16.0}) {
    return CameraUpdate.newCameraPosition(
      CameraPosition(
        target: location,
        zoom: zoom,
      ),
    );
  }

  /// Fit the camera to display a route between two points
  static CameraUpdate fitToPoints(LatLng point1, LatLng point2, {double padding = 100.0}) {
    final bounds = RouteUtils.createBoundsFromPoints(point1, point2);
    return CameraUpdate.newLatLngBounds(bounds, padding);
  }

  /// Fit the camera to display all points in a list
  static CameraUpdate fitToPointsList(List<LatLng> points, {double padding = 100.0}) {
    if (points.isEmpty) {
      throw ArgumentError('Points list cannot be empty');
    }

    if (points.length == 1) {
      return centerOnLocation(points.first);
    }

    final bounds = RouteUtils.createBoundsFromPointsList(points);
    return CameraUpdate.newLatLngBounds(bounds, padding);
  }

  /// Fit camera to a specific LatLngBounds
  static CameraUpdate fitToBounds(LatLngBounds bounds, {double padding = 100.0}) {
    return CameraUpdate.newLatLngBounds(bounds, padding);
  }

  /// Animate camera to target with custom settings
  static CameraUpdate animateTo(
    LatLng target, {
    double zoom = 15.0,
    double tilt = 0,
    double bearing = 0,
  }) {
    return CameraUpdate.newCameraPosition(
      CameraPosition(
        target: target,
        zoom: zoom,
        tilt: tilt,
        bearing: bearing,
      ),
    );
  }

  /// Apply camera update safely with error handling
  static Future<void> applyCameraUpdate(
    GoogleMapController controller,
    CameraUpdate update, {
    BuildContext? context,
  }) async {
    try {
      await controller.animateCamera(update);
    } catch (e) {
      debugPrint('Error applying camera update: $e');
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update map view')),
        );
      }
    }
  }
}
