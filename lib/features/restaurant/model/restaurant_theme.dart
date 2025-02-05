import 'package:freezed_annotation/freezed_annotation.dart';

part 'restaurant_theme.freezed.dart';
part 'restaurant_theme.g.dart';

@freezed
class RestaurantTheme with _$RestaurantTheme {
  const factory RestaurantTheme({
    required int id,
    required String name,
  }) = _RestaurantTheme;

  factory RestaurantTheme.fromJson(Map<String, dynamic> json) =>
      _$RestaurantThemeFromJson(json);
}