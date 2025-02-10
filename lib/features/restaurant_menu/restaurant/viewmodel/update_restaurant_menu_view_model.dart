import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/restaurant_menu/repository/restaurant_menu_repository.dart';
import 'package:socieaty/features/restaurant_menu/restaurant/viewstate/update_restaurant_menu_form_state.dart';
import 'package:socieaty/features/restaurant_menu/restaurant/viewstate/update_restaurant_menu_view_state.dart';
import 'package:socieaty/shared/view_state.dart';

part 'update_restaurant_menu_view_model.g.dart';

@riverpod
class UpdateRestaurantMenuViewModel extends _$UpdateRestaurantMenuViewModel {
  late RestaurantMenuRepository _restaurantMenuRepository;

  @override
  UpdateRestaurantMenuViewState build(String menuId) {
    _restaurantMenuRepository = ref.watch(restaurantMenuRepositoryProvider);
    return UpdateRestaurantMenuViewState(
      menuId: menuId,
      updateMenuState: IdleState(),
    );
  }

  Future<void> updateRestaurantMenu(UpdateRestaurantMenuFormState data, File? menuPicture) async {
    state = state.copyWith(updateMenuState: LoadingState());
    final result =
        await _restaurantMenuRepository.updateRestaurantMenu(state.menuId, data, menuPicture);
    switch (result) {
      case Success(data: final result):
        state = state.copyWith(updateMenuState: SuccessState(data: result.menu));
      case Error(message: final message):
        state = state.copyWith(updateMenuState: ErrorState(message: message));
    }
  }
}
