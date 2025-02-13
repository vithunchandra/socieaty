import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/restaurant_menu/repository/response/delete_food_menu_response.dart';
import 'package:socieaty/features/restaurant_menu/repository/response/update_food_menu_stock_availablity.dart';
import 'package:socieaty/features/restaurant_menu/repository/food_menu_repository.dart';
import 'package:socieaty/features/restaurant_menu/restaurant/viewstate/food_menu_detail_widget_view_state.dart';
import 'package:socieaty/shared/view_state.dart';

part 'food_menu_detail_widget_view_model.g.dart';

@riverpod
class FoodMenuDetailWidgetViewModel extends _$FoodMenuDetailWidgetViewModel {
  late FoodMenuRepository _restaurantMenuRepository;

  @override
  FoodMenuDetailWidgetViewState build(String menuId) {
    _restaurantMenuRepository = ref.watch(foodMenuRepositoryProvider);
    return FoodMenuDetailWidgetViewState(
      menuId: menuId,
      updatedMenu: IdleState(),
      deletedMenuMessage: IdleState(),
    );
  }

  Future<void> updateMenuStock(String menuId, bool isAvailable) async {
    state = state.copyWith(updatedMenu: LoadingState());
    final result = await _restaurantMenuRepository.updateFoodMenuStock(menuId, isAvailable);
    switch (result) {
      case Success<UpdateFoodMenuStockAvailabilityResponse>(data: final data):
        state = state.copyWith(updatedMenu: SuccessState(data: data.updatedMenu));
      case Error(message: final message):
        state = state.copyWith(updatedMenu: ErrorState(message: message));
    }
  }

  Future<void> deleteMenu() async {
    state = state.copyWith(deletedMenuMessage: LoadingState());
    final result = await _restaurantMenuRepository.deleteFoodMenu(state.menuId);
    switch (result) {
      case Success<DeleteFoodMenuResponse>(data: final data):
        state = state.copyWith(deletedMenuMessage: SuccessState(data: data.message));
      case Error(message: final message):
        state = state.copyWith(deletedMenuMessage: ErrorState(message: message));
    }
  }
}
