import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'dart:async';

class BottomCartWidget extends StatefulWidget {
  // The main content of the screen.
  final Widget child;
  // Flag to show cart widget when there are items in the cart.
  final bool showCart;
  // Restaurant name to display in the cart.
  final String restaurantName;
  // Number of items in the cart.
  final int itemCount;
  // Total price for the items in the cart.
  final double totalPrice;
  // An optional ScrollController to listen for scroll state changes.
  final ScrollController? scrollController;
  // The fixed height for the cart widget at the bottom.
  static const double _cartHeight = 80;

  const BottomCartWidget({
    super.key,
    required this.child,
    this.showCart = false,
    this.restaurantName = 'Socieaty',
    this.itemCount = 0,
    this.totalPrice = 0.0,
    this.scrollController,
  });

  @override
  State<BottomCartWidget> createState() => _BottomCartWidgetState();
}

class _BottomCartWidgetState extends State<BottomCartWidget> {
  // This flag will track if user is scrolling.
  bool _isScrolling = false;
  Timer? _scrollEndTimer;

  // Internal state for cart items and total price.
  int _currentItemCount = 0;
  double _currentTotalPrice = 0.0;

  void _onScrollStatusChanged() {
    // Ensure the scrollController is attached to a scroll view.
    if (!widget.scrollController!.hasClients) {
      return;
    }

    // This method is triggered when the scrollController's isScrollingNotifier changes.
    final scrolling = widget.scrollController!.position.isScrollingNotifier.value;
    // Cancel any existing timer.
    _scrollEndTimer?.cancel();
    if (scrolling) {
      if (!_isScrolling) {
        setState(() {
          _isScrolling = true;
        });
      }
    } else {
      // When scrolling stops, wait for 300ms before showing the bottom cart.
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
    // Initialize internal cart state from the widget.
    _currentItemCount = widget.itemCount;
    _currentTotalPrice = widget.totalPrice;

    // If a scrollController is provided, wait for the first frame so that it's attached,
    // then add a listener to its isScrollingNotifier.
    if (widget.scrollController != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.scrollController!.hasClients) {
          widget.scrollController!.position.isScrollingNotifier.addListener(_onScrollStatusChanged);
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant BottomCartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      // Remove listener from the old scrollController if attached.
      if (oldWidget.scrollController?.hasClients ?? false) {
        oldWidget.scrollController!.position.isScrollingNotifier
            .removeListener(_onScrollStatusChanged);
      }
      // Wait a frame before adding the listener to the new scrollController.
      if (widget.scrollController != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (widget.scrollController!.hasClients) {
            widget.scrollController!.position.isScrollingNotifier
                .addListener(_onScrollStatusChanged);
          }
        });
      }
    }
    // If parent's cart values change, update the internal state.
    if (widget.itemCount != oldWidget.itemCount || widget.totalPrice != oldWidget.totalPrice) {
      setState(() {
        _currentItemCount = widget.itemCount;
        _currentTotalPrice = widget.totalPrice;
      });
    }
  }

  void _clearCart() {
    setState(() {
      _currentItemCount = 0;
      _currentTotalPrice = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Always include the main content so that its state is preserved.
        NotificationListener<ScrollNotification>(
          onNotification: (_) => false,
          child: widget.child,
        ),
        // Conditionally show the bottom cart overlay.
        if (widget.showCart && _currentItemCount > 0)
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
                  // TODO: Handle cart button press.
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
                        _clearCart();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left side: Restaurant name and item quantity.
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.restaurantName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "$_currentItemCount items",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          // Right side: Total price.
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
                                "\$${_currentTotalPrice.toStringAsFixed(2)}",
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
    // Remove the listener if the scrollController is attached.
    if (widget.scrollController?.hasClients ?? false) {
      widget.scrollController!.position.isScrollingNotifier.removeListener(_onScrollStatusChanged);
    }
    _scrollEndTimer?.cancel();
    super.dispose();
  }
}
