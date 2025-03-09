import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/features/food_menu/provider/menu_cart_view_model.dart';
import 'dart:async';

import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';

class BottomCartWidget extends ConsumerStatefulWidget {
  final Widget child;
  final SocieatyRestaurant restaurant;
  final ScrollController? scrollController;
  static const double _cartHeight = 80;

  const BottomCartWidget({
    super.key,
    required this.child,
    required this.restaurant,
    this.scrollController,
  });

  @override
  ConsumerState<BottomCartWidget> createState() => _BottomCartWidgetState();
}

class _BottomCartWidgetState extends ConsumerState<BottomCartWidget> {
  bool _isScrolling = false;
  SocieatyRestaurant? _currentRestaurant;
  Timer? _scrollEndTimer;

  void _onScrollStatusChanged() {
    if (!widget.scrollController!.hasClients) {
      return;
    }
    final scrolling = widget.scrollController!.position.isScrollingNotifier.value;
    _scrollEndTimer?.cancel();
    if (scrolling) {
      if (!_isScrolling) {
        setState(() {
          _isScrolling = true;
        });
      }
    } else {
      _scrollEndTimer = Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _isScrolling = false;
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.scrollController != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.scrollController!.hasClients) {
          widget.scrollController!.position.isScrollingNotifier.addListener(_onScrollStatusChanged);
        }
      });
    }
    _currentRestaurant = widget.restaurant;
  }

  @override
  void didUpdateWidget(covariant BottomCartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      if (oldWidget.scrollController?.hasClients ?? false) {
        oldWidget.scrollController!.position.isScrollingNotifier
            .removeListener(_onScrollStatusChanged);
      }
      if (widget.scrollController != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (widget.scrollController!.hasClients) {
            widget.scrollController!.position.isScrollingNotifier
                .addListener(_onScrollStatusChanged);
          }
        });
      }
    }
    if (widget.restaurant.id != oldWidget.restaurant.id) {
      setState(() {
        _currentRestaurant = widget.restaurant;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = ref.watch(menuCartViewModelProvider(widget.restaurant.id)).menuItems;
    final isThereItemsInCart = menuItems.isNotEmpty;
    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (_) => false,
          child: widget.child,
        ),
        if (isThereItemsInCart)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: 0,
            right: 0,
            bottom: _isScrolling ? -BottomCartWidget._cartHeight : 0,
            child: Container(
              height: BottomCartWidget._cartHeight,
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  context.push("/${widget.restaurant.id}/shop/order", extra: widget.restaurant);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPallete.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: ClipRRect(
                    clipBehavior: Clip.antiAlias,
                    child: Dismissible(
                      key: const Key('bottomCartDismissible'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        decoration: BoxDecoration(
                          color: AppPallete.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: const Icon(Icons.clear, color: Colors.white, size: 24),
                          ),
                        ),
                      ),
                      onDismissed: (_) {
                        ref
                            .read(menuCartViewModelProvider(widget.restaurant.id).notifier)
                            .clearCart();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.shopping_cart,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _currentRestaurant?.name ?? '',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${menuItems.fold(0, (sum, item) => sum + item.quantity)} items",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Total",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "Rp ${menuItems.fold(0, (sum, item) => sum + item.quantity * item.menuItem.price).toIDRFormat()}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    if (widget.scrollController?.hasClients ?? false) {
      widget.scrollController!.position.isScrollingNotifier.removeListener(_onScrollStatusChanged);
    }
    _scrollEndTimer?.cancel();
    super.dispose();
  }
}
