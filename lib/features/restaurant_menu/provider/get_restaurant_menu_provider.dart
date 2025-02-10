import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/restaurant_menu/model/restaurant_menu.dart';
import 'package:socieaty/features/restaurant_menu/repository/restaurant_menu_repository.dart';

part 'get_restaurant_menu_provider.g.dart';

@riverpod
Future<List<RestaurantMenu>> getRestaurantMenus(Ref ref) async {
  final result = await ref.watch(restaurantMenuRepositoryProvider).getAllRestaurantMenu();
  switch(result){
    case Success(data: final menus):
      return menus.menus;
    case Error(message: final message):
      throw Exception(message);
  }
}