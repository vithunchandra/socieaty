import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/restaurant_menu/repository/restaurant_menu_repository.dart';
import 'package:socieaty/features/restaurant_menu/restaurant/viewstate/create_restaurant_menu_form_state.dart';
import 'package:socieaty/features/restaurant_menu/restaurant/viewstate/create_restaurant_menu_view_state.dart';
import 'package:socieaty/shared/view_state.dart';

part 'create_restaurant_menu_view_model.g.dart';

@riverpod
class CreateRestaurantMenuViewModel extends _$CreateRestaurantMenuViewModel {
  late RestaurantMenuRepository _restaurantMenuRepository;

  @override
  CreateRestaurantMenuViewState build() {
    _restaurantMenuRepository = ref.watch(restaurantMenuRepositoryProvider);
    return CreateRestaurantMenuViewState(
      createMenuState: IdleState(),
    );
  }

  Future<void> createRestaurantMenu(CreateRestaurantMenuFormState data, File menuPicture) async {
    state = state.copyWith(createMenuState: LoadingState());
    final result = await _restaurantMenuRepository.createRestaurantMenu(data, menuPicture);
    switch (result) {
      case Success(data: final result):
        state = state.copyWith(createMenuState: SuccessState(data: result.menu));
      case Error(message: final message):
        state = state.copyWith(createMenuState: ErrorState(message: message));
    }
  }
}
