import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Helper class for managing Google Maps markers
class MapMarkersHelper {
  /// Create a marker for the current user location
  static Marker createCurrentLocationMarker({
    required LatLng position,
    bool draggable = false,
    Function(LatLng)? onDragEnd,
  }) {
    return Marker(
      markerId: const MarkerId('current_location'),
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: const InfoWindow(title: 'Your Location'),
      draggable: draggable,
      onDragEnd: onDragEnd,
    );
  }

  /// Create a marker for the destination/target location
  static Marker createDestinationMarker({
    required LatLng position,
    required String title,
    String? snippet,
  }) {
    return Marker(
      markerId: const MarkerId('target_location'),
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(
        title: title,
        snippet: snippet,
      ),
    );
  }

  /// Create a custom marker with specific color and id
  static Marker createCustomMarker({
    required String id,
    required LatLng position,
    required double hue,
    String? title,
    String? snippet,
    bool draggable = false,
    Function(LatLng)? onDragEnd,
  }) {
    return Marker(
      markerId: MarkerId(id),
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(hue),
      infoWindow: InfoWindow(
        title: title,
        snippet: snippet,
      ),
      draggable: draggable,
      onDragEnd: onDragEnd,
    );
  }

  /// Update current location marker in a marker set
  static Set<Marker> updateCurrentLocationMarker(Set<Marker> markers, LatLng newPosition,
      {bool draggable = false, Function(LatLng)? onDragEnd}) {
    markers.removeWhere((marker) => marker.markerId.value == 'current_location');
    markers.add(createCurrentLocationMarker(
      position: newPosition,
      draggable: draggable,
      onDragEnd: onDragEnd,
    ));
    return markers;
  }
}
