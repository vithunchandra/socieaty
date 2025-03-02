import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/food_menu/customer/view/transaction_food_menu_item_widget.dart';
import 'package:socieaty/features/food_menu/model/menu_cart.dart';
import 'package:socieaty/features/food_menu/provider/menu_cart_view_model.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';
import 'package:socieaty/features/transaction/customer/viewmodel/create_transaction_view_model.dart';
import 'package:socieaty/features/transaction/customer/viewstate/create_transaction_form_state.dart';
import 'package:socieaty/features/transaction/customer/viewstate/order_menu_item.dart';
import 'package:socieaty/features/transaction/model/food_order_transaction.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/custom_text_field.dart';
import 'package:socieaty/shared/widgets/dotted_divider.dart';

class CreateTransactionScreen extends ConsumerStatefulWidget {
  final SocieatyRestaurant restaurant;

  const CreateTransactionScreen({super.key, required this.restaurant});

  @override
  ConsumerState<CreateTransactionScreen> createState() => _CreateTransactionScreenState();
}

class _CreateTransactionScreenState extends ConsumerState<CreateTransactionScreen> {
  final ScrollController _scrollController = ScrollController();
  final _containerKey = GlobalKey();
  Size? _containerSize;
  bool _isCollapsed = false;
  String _additionalNotes = "";
  late CreateTransactionFormState _formState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getContainerSize();
    });
    _scrollController.addListener(onScroll);
    _formState = CreateTransactionFormState(
      restaurantId: widget.restaurant.restaurantData.id,
      serviceType: TransactionServiceType.foodOrder,
      menuItems: [],
      note: "",
    );
  }

  void getContainerSize() {
    if (_containerKey.currentContext != null) {
      final RenderBox renderBox = _containerKey.currentContext!.findRenderObject() as RenderBox;
      setState(() {
        _containerSize = renderBox.size;
      });
    }
  }

  void onScroll() {
    if (_containerSize == null) return;
    if (_scrollController.hasClients) {
      if (_scrollController.offset >= _containerSize!.height + 16 && !_isCollapsed) {
        setState(() {
          _isCollapsed = true;
        });
      } else if (_scrollController.offset < _containerSize!.height + 16 && _isCollapsed) {
        setState(() {
          _isCollapsed = false;
        });
      }
    }
  }

  void createTransaction(List<MenuCart> cartItems) {
    if (cartItems.isEmpty) {
      showSnackbar(context, "Cart is empty", isError: true);
      return;
    }
    _formState = _formState.copyWith(
      menuItems: cartItems
          .map((e) => OrderMenuItem(
                menuId: e.menuItem.id,
                quantity: e.quantity,
              ))
          .toList(),
      note: _additionalNotes,
    );
    debugPrint(_formState.toJson().toString());
    ref.read(createTransactionViewModelProvider.notifier).createTransaction(_formState);
  }

  void _showAdditionalNoteModal(BuildContext context) {
    TextEditingController textController = TextEditingController(text: _additionalNotes);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Catatan Tambahan",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: textController,
                maxLines: 5,
                minLines: 1,
                hintText: "Masukan catatan tambahan...",
              ),
              const SizedBox(height: 8),
              Text(
                "Restaurant akan berusaha untuk memenuhi permintaanmu. Namun orderan tidak bisa dibatalkan ataupun direfund jika permintaanmu tidak terpenuhi.",
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppPallete.neutralColor.shade500),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () {
                    setState(() {
                      _additionalNotes = textController.text;
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text("Save Note"),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(menuCartViewModelProvider(widget.restaurant.id)).menuItems;
    final totalPrice = cartItems.fold(0, (sum, item) => sum + item.quantity * item.menuItem.price);
    final subtotal = totalPrice;
    final applicationFee = 5000;
    final grandTotal = subtotal + applicationFee;

    ref.listen(menuCartViewModelProvider(widget.restaurant.id), (previous, next) {
      if (next.menuItems.isEmpty) {
        context.pop();
      }
    });

    ref.listen(createTransactionViewModelProvider, (_, next) {
      switch (next.formState) {
        case SuccessState<FoodOrderTransaction>(data: final data):
          debugPrint(data.toString());
          ref.read(menuCartViewModelProvider(widget.restaurant.id).notifier).clearCart();
          context.push('/track-order', extra: data.id);
        case ErrorState(message: final message):
          showSnackbar(context, message, isError: true);
        case LoadingState():
        case IdleState():
      }
    });

    return Scaffold(
      backgroundColor: AppPallete.neutralColor.shade50,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: AppPallete.neutralColor.shade50,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: _isCollapsed
            ? Row(
                children: [
                  CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                      widget.restaurant.restaurantData.restaurantBannerUrl,
                    ),
                    radius: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.restaurant.name,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  )
                ],
              )
            : Text("Order Food"),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Text(
                "Your cart is empty",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14),
              ),
            )
          : SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    key: _containerKey,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppPallete.neutralColor.shade200,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.restaurant.name,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: AppPallete.primaryColor, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "123 Dummy Street, Jakarta",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.directions_walk, color: AppPallete.primaryColor, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              "2 km away",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.timer, color: AppPallete.primaryColor, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              "15 mins",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () {},
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: const Text("Ubah Lokasi Saya"),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Detail orderan",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  const DottedDivider(color: AppPallete.neutralColor),
                  const SizedBox(height: 16),

                  // Order Items
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cartItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Column(
                        children: [
                          TransactionFoodMenuItemWidget(
                            menuCart: item,
                            onDecrement: () {
                              ref
                                  .read(menuCartViewModelProvider(widget.restaurant.id).notifier)
                                  .removeMenuFromCart(item.menuItem);
                            },
                            onIncrement: () {
                              ref
                                  .read(menuCartViewModelProvider(widget.restaurant.id).notifier)
                                  .addMenuToCart(item.menuItem);
                            },
                          ),
                          if (index < cartItems.length - 1)
                            const DottedDivider(color: AppPallete.neutralColor),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showAdditionalNoteModal(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppPallete.primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          icon: Icon(
                            Icons.description,
                            color: AppPallete.primaryColor,
                          ),
                          label: Text(
                            _additionalNotes.isEmpty
                                ? "Add Additional Note"
                                : "Edit Additional Note",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppPallete.primaryColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_additionalNotes.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppPallete.neutralColor.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Note: $_additionalNotes",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                  const SizedBox(height: 24),
                  Text(
                    "Rincian pembayaran",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),

                  const DottedDivider(color: AppPallete.neutralColor),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppPallete.primaryColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Rangkuman Pembayaran",
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 16),
                        // Detailed breakdown of each cart item
                        Column(
                          children: cartItems.map((item) {
                            final itemTotal = item.menuItem.price * item.quantity;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "${item.menuItem.name} x${item.quantity}",
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    itemTotal.toIDRFormat(),
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        // Dotted Divider before the pricing breakdown
                        DottedDivider(color: AppPallete.neutralColor),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Subtotal",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              subtotal.toIDRFormat(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Application Fee",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              applicationFee.toIDRFormat(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const Divider(height: 24, thickness: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total Payment",
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            Text(
                              grandTotal.toIDRFormat(),
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppPallete.neutralColor.shade50,
                boxShadow: [
                  BoxShadow(
                    color: AppPallete.neutralColor.shade200,
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total",
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Text(
                        grandTotal.toIDRFormat(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        createTransaction(cartItems);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppPallete.primaryColor,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: Text("Order The Food"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
