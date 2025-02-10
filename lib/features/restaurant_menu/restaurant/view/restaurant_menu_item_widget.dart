import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/restaurant_menu/model/restaurant_menu.dart';
import 'package:socieaty/features/restaurant_menu/restaurant/view/restaurant_menu_detail_widget.dart';
import 'package:socieaty/features/restaurant_menu/restaurant/viewmodel/restaurant_menu_item_widget_view_model.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/image_error_widget.dart';
import 'package:socieaty/shared/widgets/image_loading_widget.dart';

class RestaurantMenuItemWidget extends ConsumerStatefulWidget {
  final RestaurantMenu restaurantMenu;
  const RestaurantMenuItemWidget({super.key, required this.restaurantMenu});

  @override
  ConsumerState<RestaurantMenuItemWidget> createState() => _RestaurantMenuItemWidgetState();
}

class _RestaurantMenuItemWidgetState extends ConsumerState<RestaurantMenuItemWidget> {
  bool _isAvailable = true;
  late RestaurantMenu _menu;
  Timer? _debounce;
  final Duration _debounceDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _menu = widget.restaurantMenu;
    _isAvailable = _menu.isStockAvailable;
  }

  @override
  void didUpdateWidget(RestaurantMenuItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.restaurantMenu.id != widget.restaurantMenu.id) {
      _menu = widget.restaurantMenu;
      _isAvailable = _menu.isStockAvailable;
    }
  }

  _onSwitch() {
    setState(() {
      _isAvailable = !_isAvailable;
    });
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(_debounceDuration, () {
      ref
          .read(restaurantMenuItemWidgetViewModelProvider(_menu.id).notifier)
          .updateMenuStock(_menu.id, _isAvailable);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(restaurantMenuItemWidgetViewModelProvider(_menu.id), (previous, current) {
      switch (current.updatedMenu) {
        case SuccessState(data: final data):
          setState(() {
            _menu = data;
            _isAvailable = _menu.isStockAvailable;
          });
        case ErrorState(message: final message):
          showSnackbar(context, message, isError: true);
        case LoadingState():
        case IdleState():
        // No action needed for idle state
      }
    });

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: AppPallete.neutralColor.shade50,
          enableDrag: true,
          useRootNavigator: true,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (context) => RestaurantMenuDetailWidget(
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
                    Text(widget.restaurantMenu.name.toCapitalized(),
                        style: Theme.of(context).textTheme.titleMedium),
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
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _onSwitch();
                        },
                        child: Container(
                          width: 100,
                          padding: EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                                color:
                                    _isAvailable ? AppPallete.successColor : AppPallete.errorColor),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_isAvailable ? "Tersedia" : "Kosong",
                                  style: Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(width: 4),
                              Icon(_isAvailable ? Icons.check_circle : Icons.close,
                                  color: _isAvailable
                                      ? AppPallete.successColor
                                      : AppPallete.errorColor,
                                  size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
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
                            child: Image.network(
                              widget.restaurantMenu.pictureUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                return imageLoadingWidget(context, child, loadingProgress);
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return imageErrorWidget(context, error, stackTrace);
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: SizedBox(
                              width: 100,
                              height: 40,
                              child: FilledButton(
                                onPressed: () {
                                  context.push(
                                    '/restaurant/dashboard/outlet/menu/update',
                                    extra: widget.restaurantMenu,
                                  );
                                },
                                child: Text("Edit"),
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
