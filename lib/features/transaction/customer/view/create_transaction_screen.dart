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
                  // Restaurant Information Card - Transaction-focused design
                  Container(
                    key: _containerKey,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Restaurant header with compact image
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Restaurant image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: widget.restaurant.restaurantData.restaurantBannerUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.restaurant, color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Restaurant info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.restaurant.name,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: AppPallete.primaryColor,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          "123 Dummy Street, Jakarta",
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Colors.grey[600],
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: DottedDivider(color: AppPallete.neutralColor),
                        ),

                        // Delivery info row
                        Row(
                          children: [
                            // Estimated time
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppPallete.primaryColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.access_time,
                                      color: AppPallete.primaryColor,
                                      size: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Delivery Time",
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              color: Colors.grey[500],
                                            ),
                                      ),
                                      Text(
                                        "15-20 mins",
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[800],
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Distance info
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppPallete.primaryColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.directions_walk,
                                      color: AppPallete.primaryColor,
                                      size: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Distance",
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              color: Colors.grey[500],
                                            ),
                                      ),
                                      Text(
                                        "2 km away",
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[800],
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Location update button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: Icon(
                              Icons.my_location,
                              size: 16,
                              color: AppPallete.primaryColor,
                            ),
                            label: Text(
                              "Update My Location",
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: AppPallete.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              side: BorderSide(color: AppPallete.primaryColor.withOpacity(0.5)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Order Details Section - Enhanced
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        color: AppPallete.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Order Details",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Order Items - Enhanced
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cartItems.length,
                      separatorBuilder: (_, __) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const DottedDivider(color: AppPallete.neutralColor),
                      ),
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: TransactionFoodMenuItemWidget(
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
                        );
                      },
                    ),
                  ),

                  // Additional Notes Section - Enhanced
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.note_alt,
                              color: AppPallete.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Additional Notes",
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _additionalNotes.isEmpty
                            ? OutlinedButton.icon(
                                onPressed: () => _showAdditionalNoteModal(context),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppPallete.primaryColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  minimumSize: const Size(double.infinity, 48),
                                ),
                                icon: Icon(
                                  Icons.add,
                                  color: AppPallete.primaryColor,
                                  size: 16,
                                ),
                                label: Text(
                                  "Add Note",
                                  style: TextStyle(
                                    color: AppPallete.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppPallete.neutralColor.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppPallete.neutralColor.shade300),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.sticky_note_2_outlined,
                                          color: AppPallete.primaryColor,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _additionalNotes,
                                            style: Theme.of(context).textTheme.bodyMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: () => _showAdditionalNoteModal(context),
                                    icon: Icon(
                                      Icons.edit,
                                      size: 14,
                                      color: AppPallete.primaryColor,
                                    ),
                                    label: Text(
                                      "Edit Note",
                                      style: TextStyle(
                                        color: AppPallete.primaryColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),

                  // Payment Details Section - Already Enhanced
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(
                        Icons.payments_outlined,
                        color: AppPallete.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Payment Details",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.receipt_long,
                              color: AppPallete.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Order Summary',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const Spacer(),
                            Text(
                              '${cartItems.length} items',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const DottedDivider(color: AppPallete.neutralColor),
                        const SizedBox(height: 12),

                        // Compact order items list
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: cartItems.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final item = cartItems[index];
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Quantity
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: AppPallete.primaryColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      item.quantity.toString(),
                                      style: TextStyle(
                                        color: AppPallete.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Item name
                                Expanded(
                                  child: Text(
                                    item.menuItem.name,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Price
                                Text(
                                  (item.menuItem.price * item.quantity).toIDRFormat(),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            );
                          },
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: DottedDivider(color: AppPallete.neutralColor),
                        ),

                        // Payment Details with improved styling
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtotal',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              subtotal.toIDRFormat(),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Application Fee',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              applicationFee.toIDRFormat(),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Container(
                            height: 1,
                            color: AppPallete.neutralColor.shade300,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Payment',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              grandTotal.toIDRFormat(),
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppPallete.primaryColor,
                                  ),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total Payment",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          grandTotal.toIDRFormat(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppPallete.primaryColor,
                              ),
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
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Order Now",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
