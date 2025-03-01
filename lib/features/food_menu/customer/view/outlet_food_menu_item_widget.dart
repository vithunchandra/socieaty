import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/features/food_menu/customer/view/outlet_food_menu_detail_widget.dart';
import 'package:socieaty/features/food_menu/model/food_menu.dart';
import 'package:socieaty/features/food_menu/provider/menu_cart_view_model.dart';
import 'package:socieaty/shared/widgets/image_error_widget.dart';
import 'package:socieaty/shared/widgets/image_loading_widget.dart';

class OutletFoodMenuItemWidget extends ConsumerStatefulWidget {
  final String restaurantId;
  final FoodMenu restaurantMenu;
  const OutletFoodMenuItemWidget({
    super.key,
    required this.restaurantId,
    required this.restaurantMenu,
  });

  @override
  ConsumerState<OutletFoodMenuItemWidget> createState() => _OutletFoodMenuItemWidgetState();
}

class _OutletFoodMenuItemWidgetState extends ConsumerState<OutletFoodMenuItemWidget> {
  bool _isAvailable = true;
  late FoodMenu _menu;

  @override
  void initState() {
    super.initState();
    _menu = widget.restaurantMenu;
    _isAvailable = _menu.isStockAvailable;
  }

  // @override
  // void didUpdateWidget(RestaurantFoodMenuItemWidget oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   _menu = widget.restaurantMenu;
  //   _isAvailable = _menu.isStockAvailable;
  // }

  @override
  Widget build(BuildContext context) {
    final menuCart = ref.watch(
      menuCartViewModelProvider(widget.restaurantId).select(
        (value) => value.menuItems.firstWhereOrNull((e) => e.menuItem.id == _menu.id),
      ),
    );

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).focusedChild?.unfocus();
        showModalBottomSheet(
          context: context,
          backgroundColor: AppPallete.neutralColor.shade50,
          enableDrag: true,
          useRootNavigator: true,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (context) => OutletFoodMenuDetailWidget(
            restaurantId: widget.restaurantId,
            restaurantMenu: _menu,
          ),
        );
      },
      behavior: HitTestBehavior.deferToChild,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.restaurantMenu.name.toCapitalized(),
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.restaurantMenu.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12),
                    Text("Rp ${widget.restaurantMenu.price.toIDRFormat()}",
                        style: Theme.of(context).textTheme.titleSmall)
                  ],
                ),
              ),
              SizedBox(width: 24),
              Column(
                children: [
                  Container(
                    width: 100,
                    padding: EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                          color: _isAvailable ? AppPallete.successColor : AppPallete.errorColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_isAvailable ? "Tersedia" : "Kosong",
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(width: 4),
                        Icon(_isAvailable ? Icons.check_circle : Icons.close,
                            color: _isAvailable ? AppPallete.successColor : AppPallete.errorColor,
                            size: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 120,
                    height: 140,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CachedNetworkImage(
                              imageUrl: widget.restaurantMenu.pictureUrl,
                              fit: BoxFit.cover,
                              progressIndicatorBuilder: (context, url, progress) =>
                                  imageLoadingWidget(context, url, progress),
                              errorWidget: (context, url, error) =>
                                  imageErrorWidget(context, error, null),
                              memCacheWidth: 240,
                              memCacheHeight: 240,
                              maxWidthDiskCache: 240,
                              maxHeightDiskCache: 240,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: menuCart == null
                                ? SizedBox(
                                    width: 100,
                                    height: 40,
                                    child: FilledButton(
                                      onPressed: () {
                                        ref
                                            .read(menuCartViewModelProvider(widget.restaurantId)
                                                .notifier)
                                            .addMenuToCart(widget.restaurantMenu);
                                      },
                                      child: Text("Tambah"),
                                    ),
                                  )
                                : PhysicalModel(
                                    color: AppPallete.primaryColor,
                                    borderRadius: BorderRadius.circular(10),
                                    elevation: 1,
                                    child: Container(
                                      width: 100,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: 32,
                                            child: TextButton(
                                              onPressed: () {
                                                ref
                                                    .read(menuCartViewModelProvider(
                                                            widget.restaurantId)
                                                        .notifier)
                                                    .removeMenuFromCart(widget.restaurantMenu);
                                              },
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                padding: EdgeInsets.zero,
                                                minimumSize: Size(32, 36),
                                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              ),
                                              child:
                                                  Icon(Icons.remove, size: 20, color: Colors.white),
                                            ),
                                          ),
                                          Text(
                                            menuCart.quantity.toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(color: Colors.white),
                                          ),
                                          SizedBox(
                                            width: 32,
                                            child: TextButton(
                                              onPressed: () {
                                                ref
                                                    .read(menuCartViewModelProvider(
                                                            widget.restaurantId)
                                                        .notifier)
                                                    .addMenuToCart(widget.restaurantMenu);
                                              },
                                              style: TextButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                padding: EdgeInsets.zero,
                                                minimumSize: Size(32, 36),
                                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              ),
                                              child: Icon(Icons.add, size: 20, color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
