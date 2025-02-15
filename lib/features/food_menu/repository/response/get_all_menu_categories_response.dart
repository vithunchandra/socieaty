import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/food_menu/model/menu_category.dart';

part 'get_all_menu_categories_response.freezed.dart';
part 'get_all_menu_categories_response.g.dart';

@freezed
class GetAllMenuCategoriesResponse with _$GetAllMenuCategoriesResponse {
  const factory GetAllMenuCategoriesResponse({
    required List<MenuCategory> categories,
  }) = _GetAllMenuCategoriesResponse;

  factory GetAllMenuCategoriesResponse.fromJson(Map<String, dynamic> json) =>
      _$GetAllMenuCategoriesResponseFromJson(json);
}
