import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socieaty/core/utils/LatLngConverter.dart';

part 'restaurant_data.freezed.dart';
part 'restaurant_data.g.dart';

@freezed
class RestaurantData with _$RestaurantData {
  const factory RestaurantData({
    required String photoUrl,
    @LatLngConverter() required LatLng location,
  }) = _RestaurantData;

  factory RestaurantData.fromJson(Map<String, dynamic> json) => _$RestaurantDataFromJson(json);
}
