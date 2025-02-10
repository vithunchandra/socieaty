import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socieaty/core/enums/bank.enum.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/restaurant/model/restaurant_theme.dart';

part 'restaurant_data.freezed.dart';
part 'restaurant_data.g.dart';

@freezed
class RestaurantData with _$RestaurantData {
  const factory RestaurantData({
    required String id,
    required String restaurantBannerUrl,
    @LatLngConverter() required LatLng location,
    required List<RestaurantTheme> themes,
    required BankEnum payoutBank,
    required String accountNumber,
    required String openTime,
    required String closeTime,
  }) = _RestaurantData;

  factory RestaurantData.fromJson(Map<String, dynamic> json) => _$RestaurantDataFromJson(json);
}
