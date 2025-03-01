import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/food_menu/repository/food_menu_repository.dart';
import 'package:socieaty/features/food_menu/repository/response/paginate_food_menu_response.dart';
import 'package:socieaty/features/food_menu/restaurant/viewstate/paginate_menu_form_state.dart';

part 'paginate_menu_provider.g.dart';

@riverpod
Future<PaginateFoodMenuResponse> paginateMenu(Ref ref, PaginateMenuFormState query) async {
  final repository = ref.watch(foodMenuRepositoryProvider);
  final result = await repository.getPaginatedFoodMenu(query);
  switch (result) {
    case Success(data: final data):
      return data;
    case Error(error: final error):
      throw Exception(error.message);
  }
}

