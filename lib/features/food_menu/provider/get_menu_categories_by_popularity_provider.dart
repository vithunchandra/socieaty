import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/food_menu/model/menu_category.dart';
import 'package:socieaty/features/food_menu/repository/food_menu_repository.dart';

part 'get_menu_categories_by_popularity_provider.g.dart';

@riverpod
Future<List<MenuCategory>> getMenuCategoriesByPopularity(Ref ref) async {
  final repository = ref.read(foodMenuRepositoryProvider);
  final result = await repository.getMenuCategoriesByPopularity();
  switch (result) {
    case Success(data: final data):
      return data.categories;
    case Error(error: final error):
      throw Exception(error.message);
  }
}
