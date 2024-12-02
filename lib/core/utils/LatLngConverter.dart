import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LatLngConverter implements JsonConverter<LatLng, Map<String, dynamic>> {
  const LatLngConverter();

  @override
  LatLng fromJson(Map<String, dynamic> json) {
    return LatLng(
      double.parse(json['latitude']),
      double.parse(json['longitude']),
    );
  }

  @override
  Map<String, dynamic> toJson(LatLng object) {
    return {
      'latitude': object.latitude,
      'longitude': object.longitude,
    };
  }
}
