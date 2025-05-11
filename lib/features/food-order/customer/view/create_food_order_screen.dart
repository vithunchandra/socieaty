import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/food_menu/customer/view/transaction_food_menu_item_widget.dart';
import 'package:socieaty/features/food_menu/model/menu_cart.dart';
import 'package:socieaty/features/food_menu/provider/menu_cart_view_model.dart';
import 'package:socieaty/features/menu_item/model/menu_cart_item.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';
import 'package:socieaty/features/food-order/customer/viewmodel/create_transaction_view_model.dart';
import 'package:socieaty/features/food-order/customer/viewstate/create_food_order_form_state.dart';
import 'package:socieaty/features/food-order/model/food_order_transaction.dart';
import 'package:socieaty/features/map/view/tracking_map.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/custom_text_field.dart';
import 'package:socieaty/shared/widgets/dotted_divider.dart';
import 'package:socieaty/core/utils/location_handler.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';
import 'package:socieaty/shared/widgets/profile_picture_widget.dart';

class CreateFoodOrderScreen extends ConsumerStatefulWidget {
  final SocieatyRestaurant restaurant;

  const CreateFoodOrderScreen({super.key, required this.restaurant});

  @override
  ConsumerState<CreateFoodOrderScreen> createState() => _CreateFoodOrderScreenState();
}

class _CreateFoodOrderScreenState extends ConsumerState<CreateFoodOrderScreen> {
  final ScrollController _scrollController = ScrollController();
  final _containerKey = GlobalKey();
  Size? _containerSize;
  bool _isCollapsed = false;
  String _additionalNotes = "";
  late CreateFoodOrderFormState _formState;
  String _locationName = "";
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getContainerSize();
    });
    _scrollController.addListener(onScroll);
    _formState = CreateFoodOrderFormState(
      restaurantId: widget.restaurant.restaurantData.id,
      serviceType: TransactionServiceType.foodOrder,
      menuItems: [],
      note: "",
    );
    getLocationName();
  }

  void getLocationName() async {
    final location =
        await LocationHandler.getAddressFromLatLng(widget.restaurant.restaurantData.location);
    _locationName = "${location?.street}";
    if (mounted) {
      setState(() {});
    }
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
      showSnackbar(context, "Keranjang kosong", state: SnackbarState.error);
      return;
    }
    _formState = _formState.copyWith(
      menuItems: cartItems
          .map((e) => MenuCartItem(
                menuId: e.menuItem.id,
                quantity: e.quantity,
              ))
          .toList(),
      note: _additionalNotes,
    );
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
                  child: const Text("Simpan Catatan"),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _navigateToMapScreen() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Get the restaurant location
      final LatLng restaurantLocation = widget.restaurant.restaurantData.location;
      final String restaurantName = widget.restaurant.name;
      // Use a more descriptive address based on what's shown in the UI
      final String restaurantAddress = _locationName;

      // Request location permission and get current location
      final locationData = await LocationHandler.getCurrentPosition();

      if (!mounted) return;

      setState(() {
        _isLoadingLocation = false;
      });

      if (locationData == null) {
        showSnackbar(
            context, 'Gagal mengambil lokasi Anda. Silakan cek pengaturan izin lokasi Anda.',
            state: SnackbarState.error);
        return;
      }

      // Use the user's actual location
      final LatLng customerLocation = LatLng(
        locationData.latitude!,
        locationData.longitude!,
      );

      // Navigate to the tracking map screen
      if (mounted) {
        context.push('/track-map',
            extra: TrackingMapArgs(
              customerLocation: customerLocation,
              targetLocation: restaurantLocation,
              targetName: restaurantName,
              targetAddress: restaurantAddress,
            ));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
        showSnackbar(context, 'Gagal membuka peta: ${e.toString()}', state: SnackbarState.error);
      }
    }
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
          ref.read(menuCartViewModelProvider(widget.restaurant.id).notifier).clearCart();
          context.push('/track-order', extra: data.orderId);
        case ErrorState(message: final message):
          showSnackbar(context, message, state: SnackbarState.error);
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
                  ProfilePictureWidget(
                    radius: 16,
                    user: UserConverter.restaurantToUser(widget.restaurant),
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
            : Text("Pesan Makanan"),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Text(
                "Keranjang kosong",
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
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: widget.restaurant.restaurantData.restaurantBannerUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[300],
                                  child: const LoadingIndicatorWidget(size: 20),
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
                                          _locationName,
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
                        // Row(
                        //   children: [
                        //     Expanded(
                        //       child: Row(
                        //         children: [
                        //           Container(
                        //             padding: const EdgeInsets.all(6),
                        //             decoration: BoxDecoration(
                        //               color: AppPallete.primaryColor.withAlpha(25),
                        //               shape: BoxShape.circle,
                        //             ),
                        //             child: Icon(
                        //               Icons.access_time,
                        //               color: AppPallete.primaryColor,
                        //               size: 14,
                        //             ),
                        //           ),
                        //           const SizedBox(width: 8),
                        //           Column(
                        //             crossAxisAlignment: CrossAxisAlignment.start,
                        //             children: [
                        //               Text(
                        //                 "Waktu Perjalanan",
                        //                 style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        //                       color: Colors.grey[500],
                        //                     ),
                        //               ),
                        //               Text(
                        //                 "15 menit",
                        //                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        //                       fontWeight: FontWeight.w600,
                        //                       color: Colors.grey[800],
                        //                     ),
                        //               ),
                        //             ],
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //     Expanded(
                        //       child: Row(
                        //         children: [
                        //           Container(
                        //             padding: const EdgeInsets.all(6),
                        //             decoration: BoxDecoration(
                        //               color: AppPallete.primaryColor.withAlpha(25),
                        //               shape: BoxShape.circle,
                        //             ),
                        //             child: Icon(
                        //               Icons.directions_walk,
                        //               color: AppPallete.primaryColor,
                        //               size: 14,
                        //             ),
                        //           ),
                        //           const SizedBox(width: 8),
                        //           Column(
                        //             crossAxisAlignment: CrossAxisAlignment.start,
                        //             children: [
                        //               Text(
                        //                 "Jarak",
                        //                 style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        //                       color: Colors.grey[500],
                        //                     ),
                        //               ),
                        //               Text(
                        //                 "2 km",
                        //                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        //                       fontWeight: FontWeight.w600,
                        //                       color: Colors.grey[800],
                        //                     ),
                        //               ),
                        //             ],
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _isLoadingLocation ? null : _navigateToMapScreen,
                            icon: _isLoadingLocation
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: LoadingIndicatorWidget(
                                      size: 16,
                                      color: AppPallete.primaryColor,
                                    ),
                                  )
                                : Icon(
                                    Icons.my_location,
                                    size: 16,
                                    color: AppPallete.primaryColor,
                                  ),
                            label: Text(
                              _isLoadingLocation ? "Memuat..." : "Lihat di Map",
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: AppPallete.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              side: BorderSide(color: AppPallete.primaryColor.withAlpha(127)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                        "Detail Pesanan",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                      ),
                    ],
                  ),
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
                              "Catatan Tambahan",
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
                                  "Tambah Catatan",
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
                                      "Edit Catatan",
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
                        "Detail Pembayaran",
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
                              'Ringkasan Pesanan',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const Spacer(),
                            Text(
                              '${cartItems.length} item',
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
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: AppPallete.primaryColor.withAlpha(25),
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
                              'Biaya Aplikasi',
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
                              'Total Pembayaran',
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
                          "Total Biaya",
                          style: Theme.of(context).textTheme.labelLarge,
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
                              "Pesan Sekarang",
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
