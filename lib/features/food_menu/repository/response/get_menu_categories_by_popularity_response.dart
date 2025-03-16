import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/food_menu/model/menu_category.dart';

part 'get_menu_categories_by_popularity_response.freezed.dart';
part 'get_menu_categories_by_popularity_response.g.dart';

@freezed
class GetMenuCategoriesByPopularityResponse with _$GetMenuCategoriesByPopularityResponse {
  const factory GetMenuCategoriesByPopularityResponse({
    required List<MenuCategory> categories,
  }) = _GetMenuCategoriesByPopularityResponse;

  factory GetMenuCategoriesByPopularityResponse.fromJson(Map<String, dynamic> json) =>
      _$GetMenuCategoriesByPopularityResponseFromJson(json);
}
