import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/food_menu/repository/food_menu_repository.dart';
import 'package:socieaty/features/food_menu/viewstate/create_food_menu_form_state.dart';
import 'package:socieaty/features/food_menu/viewstate/create_food_menu_view_state.dart';
import 'package:socieaty/shared/view_state.dart';

part 'create_food_menu_view_model.g.dart';

@riverpod
class CreateFoodMenuViewModel extends _$CreateFoodMenuViewModel {
  late FoodMenuRepository _restaurantMenuRepository;

  @override
  CreateFoodMenuViewState build() {
    _restaurantMenuRepository = ref.watch(foodMenuRepositoryProvider);
    return CreateFoodMenuViewState(
      createMenuState: IdleState(),
    );
  }

  Future<void> createFoodMenu(CreateFoodMenuFormState data, File menuPicture) async {
    state = state.copyWith(createMenuState: LoadingState());
    final result = await _restaurantMenuRepository.createFoodMenu(data, menuPicture);
    switch (result) {
      case Success(data: final result):
        state = state.copyWith(createMenuState: SuccessState(data: result.menu));
      case Error(error: final error):
        state = state.copyWith(createMenuState: ErrorState(message: error.message));
    }
  }
}
