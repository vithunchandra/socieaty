import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:socieaty/env.dart';

abstract class LocationHandler {
  static Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    PermissionStatus permission;

    serviceEnabled = await Location.instance.serviceEnabled();
    if (!serviceEnabled) {
      // Location services are disabled. Please enable the services
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

  // static Future<String?> getAddressFromLatLng(Position position) async {
  //   try {
  //     List<Placemark> placeMarks = await placemarkFromCoordinates(position.latitude, position.longitude);
  //     Placemark place = placeMarks[0];
  //     return "${place.street}, ${place.subLocality},${place.subAdministrativeArea}, ${place.postalCode}";
  //   } catch (e) {
  //     return null;
  //   }
  // }
}
