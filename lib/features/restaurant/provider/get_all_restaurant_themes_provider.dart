import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/restaurant/model/restaurant_theme.dart';
import 'package:socieaty/features/restaurant/repository/restaurant_respository.dart';

part 'get_all_restaurant_themes_provider.g.dart';

@riverpod
Future<List<RestaurantTheme>> getAllRestaurantThemes(Ref ref) async {
  final restaurantRepository = ref.watch(restaurantRespositoryProvider);
  final result = await restaurantRepository.getAllRestaurantThemes();
  switch (result) {
    case Success(data: final data):
      return data.themes;
    case Error(error: final error):
      throw Exception(error.message);
  }
}
