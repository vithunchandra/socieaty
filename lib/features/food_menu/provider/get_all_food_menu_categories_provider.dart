import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/food_menu/model/menu_category.dart';
import 'package:socieaty/features/food_menu/repository/response/get_all_menu_categories_response.dart';
import 'package:socieaty/features/food_menu/repository/food_menu_repository.dart';

part 'get_all_food_menu_categories_provider.g.dart';

@riverpod
Future<List<MenuCategory>> getAllFoodMenuCategories(Ref ref) async {
  final repository = ref.watch(foodMenuRepositoryProvider);
  final result = await repository.getAllMenuCategories();
  switch (result) {
    case Success<GetAllMenuCategoriesResponse>(data: final data):
      return data.categories;
    case Error(error: final error):
      throw Exception(error.message);
  }
}
