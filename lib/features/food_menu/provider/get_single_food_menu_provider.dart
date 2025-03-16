import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/food_menu/model/food_menu.dart';
import 'package:socieaty/features/food_menu/repository/food_menu_repository.dart';

part 'get_single_food_menu_provider.g.dart';

@riverpod
Future<FoodMenu> getSingleFoodMenu(Ref ref, String menuId) async {
  final result = await ref.watch(foodMenuRepositoryProvider).getFoodMenu(menuId);
  switch (result) {
    case Success(data: final data):
      return data.menu;
    case Error(error: final error):
      throw Exception(error.message);
  }
}
