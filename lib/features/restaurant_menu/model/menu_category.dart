import 'package:freezed_annotation/freezed_annotation.dart';

part 'menu_category.freezed.dart';
part 'menu_category.g.dart';

@freezed
class MenuCategory with _$MenuCategory {
  const factory MenuCategory({
    required int id,
    required String name,
  }) = _MenuCategory;

  factory MenuCategory.fromJson(Map<String, dynamic> json) => _$MenuCategoryFromJson(json);
}
