import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/features/food_menu/customer/view/transaction_food_menu_detail_widget.dart';
import 'package:socieaty/features/food_menu/model/food_menu.dart';
import 'package:socieaty/features/food_menu/model/menu_cart.dart';
import 'package:socieaty/shared/widgets/image_error_widget.dart';
import 'package:socieaty/shared/widgets/image_loading_widget.dart';

class TransactionFoodMenuItemWidget extends ConsumerStatefulWidget {
  final MenuCart menuCart;
  final Function() onIncrement;
  final Function() onDecrement;
  const TransactionFoodMenuItemWidget({
    super.key,
    required this.menuCart,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  ConsumerState<TransactionFoodMenuItemWidget> createState() =>
      _TransactionFoodMenuItemWidgetState();
}

class _TransactionFoodMenuItemWidgetState extends ConsumerState<TransactionFoodMenuItemWidget> {
  late FoodMenu _menu;

  @override
  void initState() {
    super.initState();
    _menu = widget.menuCart.menuItem;
  }

  @override
  Widget build(BuildContext context) {
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
          builder: (context) => TransactionFoodMenuDetailWidget(
            restaurantMenu: _menu,
          ),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.menuCart.menuItem.name.toCapitalized(),
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                    ),
                    SizedBox(height: 12),
                    Text("Rp ${widget.menuCart.menuItem.price.toIDRFormat()}",
                        style: Theme.of(context).textTheme.titleSmall)
                  ],
                ),
              ),
              SizedBox(width: 24),
              Column(
                children: [
                  SizedBox(
                    child: Column(
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CachedNetworkImage(
                              imageUrl: widget.menuCart.menuItem.pictureUrl,
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
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                widget.onDecrement();
                              },
                              color: AppPallete.primaryColor,
                            ),
                            Text(
                              "${widget.menuCart.quantity}",
                              style:
                                  Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () {
                                widget.onIncrement();
                              },
                              color: AppPallete.primaryColor,
                            ),
                          ],
                        )
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
