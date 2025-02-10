import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/restaurant_menu/repository/response/delete_restaurant_menu_response.dart';
import 'package:socieaty/features/restaurant_menu/repository/response/update_restaurant_menu_stock_availablity.dart';
import 'package:socieaty/features/restaurant_menu/repository/restaurant_menu_repository.dart';
import 'package:socieaty/features/restaurant_menu/restaurant/viewstate/restaurant_menu_detail_widget_view_state.dart';
import 'package:socieaty/shared/view_state.dart';

part 'restaurant_menu_detail_widget_view_model.g.dart';

@riverpod
class RestaurantMenuDetailWidgetViewModel extends _$RestaurantMenuDetailWidgetViewModel {
  late RestaurantMenuRepository _restaurantMenuRepository;

  @override
  RestaurantMenuDetailWidgetViewState build(String menuId) {
    _restaurantMenuRepository = ref.watch(restaurantMenuRepositoryProvider);
    return RestaurantMenuDetailWidgetViewState(
      menuId: menuId,
      updatedMenu: IdleState(),
      deletedMenuMessage: IdleState(),
    );
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

  Future<void> deleteMenu() async {
    state = state.copyWith(deletedMenuMessage: LoadingState());
    final result = await _restaurantMenuRepository.deleteRestaurantMenu(state.menuId);
    switch (result) {
      case Success<DeleteRestaurantMenuResponse>(data: final data):
        state = state.copyWith(deletedMenuMessage: SuccessState(data: data.message));
      case Error(message: final message):
        state = state.copyWith(deletedMenuMessage: ErrorState(message: message));
    }
  }
}
