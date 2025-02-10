import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/restaurant_menu/model/menu_category.dart';
import 'package:socieaty/features/restaurant_menu/repository/response/get_all_menu_categories_response.dart';
import 'package:socieaty/features/restaurant_menu/repository/restaurant_menu_repository.dart';

part 'get_all_restaurant_menu_categories_provider.g.dart';

@Riverpod(keepAlive: true)
Future<List<MenuCategory>> getAllRestaurantMenuCategories(Ref ref) async {
  final repository = ref.watch(restaurantMenuRepositoryProvider);
  final result = await repository.getAllMenuCategories();
  switch (result) {
    case Success<GetAllMenuCategoriesResponse>(data: final data):
      return data.categories;
    case Error(message: final message):
      throw Exception(message);
  }
}
