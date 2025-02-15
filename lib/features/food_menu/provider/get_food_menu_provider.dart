import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/food_menu/model/food_menu.dart';
import 'package:socieaty/features/food_menu/repository/food_menu_repository.dart';
import 'package:socieaty/shared/widgets/menu_filter_widget.dart';

part 'get_food_menu_provider.g.dart';

@riverpod
Future<List<FoodMenu>> getFoodMenus(Ref ref, MenuFilterFormState query) async {
  final result = await ref.watch(foodMenuRepositoryProvider).getAllFoodMenu(query);
  switch (result) {
    case Success(data: final menus):
      return menus.menus;
    case Error(error: final error):
      throw Exception(error.message);
  }
}
