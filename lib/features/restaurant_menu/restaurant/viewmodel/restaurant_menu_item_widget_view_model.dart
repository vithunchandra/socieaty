import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/restaurant_menu/model/restaurant_menu.dart';
import 'package:socieaty/features/restaurant_menu/repository/response/update_restaurant_menu_stock_availablity.dart';
import 'package:socieaty/features/restaurant_menu/repository/restaurant_menu_repository.dart';
import 'package:socieaty/features/restaurant_menu/restaurant/viewstate/restaurant_menu_item_widget_view_state.dart';
import 'package:socieaty/shared/view_state.dart';

part 'restaurant_menu_item_widget_view_model.g.dart';

@riverpod
class RestaurantMenuItemWidgetViewModel extends _$RestaurantMenuItemWidgetViewModel {
  late RestaurantMenuRepository _restaurantMenuRepository;

  @override
  RestaurantMenuItemWidgetViewState build(String menuId) {
    _restaurantMenuRepository = ref.watch(restaurantMenuRepositoryProvider);
    return RestaurantMenuItemWidgetViewState(menuId: menuId, updatedMenu: IdleState());
  }

  Future<void> updateMenuStock(String menuId, bool isAvailable) async {
    state = state.copyWith(updatedMenu: LoadingState());
    final result = await _restaurantMenuRepository.updateRestaurantMenuStock(menuId, isAvailable);
    switch (result) {
      case Success<UpdateRestaurantMenuStockAvailabilityResponse>(data: final data):
        state = state.copyWith(updatedMenu: SuccessState(data: data.updatedMenu));
      case Error(message: final message):
        state = state.copyWith(updatedMenu: ErrorState(message: message));
    }
  }

  void updateMenu(RestaurantMenu menu) {
    state = state.copyWith(updatedMenu: SuccessState(data: menu));
  }
}

