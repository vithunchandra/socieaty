import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/features/food_menu/model/food_menu.dart';
import 'package:socieaty/features/food_menu/model/menu_cart.dart';
import 'package:socieaty/features/food_menu/viewstate/menu_cart_view_state.dart';

part 'menu_cart_view_model.g.dart';

@riverpod
class MenuCartViewModel extends _$MenuCartViewModel {
  @override
  MenuCartViewState build(String restaurantId) {
    return MenuCartViewState(menuItems: [], restaurantId: restaurantId);
  }

  void addMenuToCart(FoodMenu menu) {
    final isExist = state.menuItems.any((e) => e.menuItem.id == menu.id);
    if (isExist) {
      state = state.copyWith(
        menuItems: state.menuItems
            .map((e) => e.menuItem.id == menu.id ? e.copyWith(quantity: e.quantity + 1) : e)
            .toList(),
      );
    } else {
      state =
          state.copyWith(menuItems: [...state.menuItems, MenuCart(menuItem: menu, quantity: 1)]);
    }
  }

  void removeMenuFromCart(FoodMenu menu) {
    MenuCart? menuCart;
    for (final item in state.menuItems) {
      if (item.menuItem.id == menu.id) {
        menuCart = item;
        break;
      }
    }
    if (menuCart == null) {
      return;
    }
    if (menuCart.quantity == 1) {
      state = state.copyWith(
          menuItems: state.menuItems.where((e) => e.menuItem.id != menu.id).toList());
    } else {
      state = state.copyWith(
        menuItems: state.menuItems
            .map((e) => e.menuItem.id == menu.id ? e.copyWith(quantity: e.quantity - 1) : e)
            .toList(),
      );
    }
  }
}
