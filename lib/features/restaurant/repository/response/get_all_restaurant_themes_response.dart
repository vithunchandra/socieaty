import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/restaurant/model/restaurant_theme.dart';

part 'get_all_restaurant_themes_response.freezed.dart';
part 'get_all_restaurant_themes_response.g.dart';

@freezed
class GetAllRestaurantThemesResponse with _$GetAllRestaurantThemesResponse {
  const factory GetAllRestaurantThemesResponse({
    required List<RestaurantTheme> themes,
  }) = _GetAllRestaurantThemesResponse;

  factory GetAllRestaurantThemesResponse.fromJson(Map<String, dynamic> json) => _$GetAllRestaurantThemesResponseFromJson(json);
}