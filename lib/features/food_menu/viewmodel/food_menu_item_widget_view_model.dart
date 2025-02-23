import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/food_menu/model/food_menu.dart';
import 'package:socieaty/features/food_menu/repository/response/update_food_menu_stock_availablity.dart';
import 'package:socieaty/features/food_menu/repository/food_menu_repository.dart';
import 'package:socieaty/features/food_menu/viewstate/food_menu_item_widget_view_state.dart';
import 'package:socieaty/shared/view_state.dart';

part 'food_menu_item_widget_view_model.g.dart';

@riverpod
class FoodMenuItemWidgetViewModel extends _$FoodMenuItemWidgetViewModel {
  late FoodMenuRepository _restaurantMenuRepository;

  @override
  FoodMenuItemWidgetViewState build(String menuId) {
    _restaurantMenuRepository = ref.watch(foodMenuRepositoryProvider);
    return FoodMenuItemWidgetViewState(menuId: menuId, updatedMenu: IdleState());
  }

  Future<void> updateMenuStock(String menuId, bool isAvailable) async {
    state = state.copyWith(updatedMenu: LoadingState());
    final result = await _restaurantMenuRepository.updateFoodMenuStock(menuId, isAvailable);
    switch (result) {
      case Success<UpdateFoodMenuStockAvailabilityResponse>(data: final data):
        state = state.copyWith(updatedMenu: SuccessState(data: data.updatedMenu));
      case Error(error: final error):
        state = state.copyWith(updatedMenu: ErrorState(message: error.message));
    }
  }

  void updateMenu(FoodMenu menu) {
    state = state.copyWith(updatedMenu: SuccessState(data: menu));
  }
}
