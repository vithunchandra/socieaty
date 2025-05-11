import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/food_menu/model/menu_cart.dart';
import 'package:socieaty/features/reservation/customer/viewmodel/create_reservation_viewmodel.dart';
import 'package:socieaty/features/reservation/customer/viewstate/create_reservation_form_state.dart';
import 'package:socieaty/features/reservation/model/reservation.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/dotted_divider.dart';
import 'package:socieaty/shared/widgets/profile_picture_widget.dart';
import 'package:socieaty/core/utils/converter.dart';

class CreateReservationScreenArgs {
  final CreateReservationFormState formState;
  final SocieatyRestaurant restaurant;
  final List<MenuCart> menuItems;
  final String selectedTime;

  const CreateReservationScreenArgs({
    required this.formState,
    required this.restaurant,
    required this.menuItems,
    required this.selectedTime,
  });
}

class CreateReservationScreen extends ConsumerStatefulWidget {
  final CreateReservationScreenArgs args;

  const CreateReservationScreen({
    super.key,
    required this.args,
  });

  @override
  ConsumerState<CreateReservationScreen> createState() => _CreateReservationScreenState();
}

class _CreateReservationScreenState extends ConsumerState<CreateReservationScreen> {
  late CreateReservationFormState _formState;
  final TextEditingController _noteController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _containerKey = GlobalKey();
  Size? _containerSize;
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _formState = widget.args.formState;
    _noteController.text = _formState.note;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getContainerSize();
    });
    _scrollController.addListener(onScroll);
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

  @override
  void dispose() {
    _noteController.dispose();
    _scrollController.removeListener(onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateNote(String value) {
    setState(() {
      _formState = _formState.copyWith(note: value);
    });
  }

  void _showAdditionalNoteModal(BuildContext context) {
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
                "Permintaan Khusus",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                maxLines: 5,
                minLines: 1,
                onChanged: _updateNote,
                decoration: const InputDecoration(
                  hintText:
                      "Tambahkan permintaan khusus atau kebutuhan (e.g. kursi tinggi, pesta ulang tahun, dll.)",
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Restoran akan berusaha untuk memenuhi permintaan Anda, tetapi tidak dapat memastikan bahwa semua permintaan dapat dipenuhi.",
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
                    Navigator.of(context).pop();
                  },
                  child: const Text("Simpan Permintaan"),
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
    final totalPrice = widget.args.menuItems.isEmpty
        ? 0
        : widget.args.menuItems.fold(0, (sum, item) => sum + item.menuItem.price * item.quantity);

    ref.listen(createReservationViewModelProvider, (previous, next) {
      switch (next.createdReservation) {
        case SuccessState(data: final data):
          showSnackbar(context, 'Reservasi berhasil dibuat');
          context.pushReplacement(
            '/${widget.args.restaurant.id}/shop/reserve/track',
            extra: data.reservationId,
          );
        case ErrorState(message: final message):
          showSnackbar(context, message);
        case LoadingState<Reservation>():
        case IdleState():
      }
    });

    return Scaffold(
      backgroundColor: AppPallete.neutralColor.shade50,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: AppPallete.neutralColor.shade50,
        surfaceTintColor: AppPallete.neutralColor.shade50,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: _isCollapsed
            ? Row(
                children: [
                  ProfilePictureWidget(
                    radius: 16,
                    user: UserConverter.restaurantToUser(widget.args.restaurant),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.args.restaurant.name,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  )
                ],
              )
            : const Text("Confirm Reservation"),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRestaurantCard(),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: AppPallete.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  "Reservation Details",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildReservationDetailsCard(),
            const SizedBox(height: 16),
            if (widget.args.menuItems.isNotEmpty) ...[
              Row(
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    color: AppPallete.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Pre-order Items",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildPreOrderItemsCard(),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Icon(
                  Icons.note_alt,
                  color: AppPallete.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  "Special Requests",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildNotesCard(),
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
            _buildPaymentSummaryCard(totalPrice),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(totalPrice),
    );
  }

  Widget _buildRestaurantCard() {
    return Container(
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
                child: ProfilePictureWidget(
                  user: UserConverter.restaurantToUser(widget.args.restaurant),
                  radius: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.args.restaurant.name,
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
                            "Informasi lokasi",
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppPallete.primaryColor.withAlpha(15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppPallete.primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Reservasi ini tergantung pada ketersediaan restoran. Anda akan menerima konfirmasi setelah restoran menerima reservasi Anda.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppPallete.primaryColor,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationDetailsCard() {
    final reservationDate = _formState.reservationTime;
    final formattedDate =
        '${_getDayName(reservationDate.weekday)}, ${reservationDate.day} ${_getMonthName(reservationDate.month)} ${reservationDate.year}';

    // Format time properly with robust error handling
    String formattedTime = _formatTimeString(widget.args.selectedTime);

    return Container(
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppPallete.primaryColor.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: AppPallete.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tanggal',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppPallete.neutralColor.shade500,
                        ),
                  ),
                  Text(
                    formattedDate,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: DottedDivider(color: AppPallete.neutralColor),
          ),

          // Time
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppPallete.secondaryColor.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.access_time_rounded,
                  color: AppPallete.secondaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Waktu',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppPallete.neutralColor.shade500,
                        ),
                  ),
                  Text(
                    formattedTime,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: DottedDivider(color: AppPallete.neutralColor),
          ),

          // Number of People
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppPallete.infoColor.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.group_rounded,
                  color: AppPallete.infoColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jumlah Orang',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppPallete.neutralColor.shade500,
                        ),
                  ),
                  Text(
                    '${_formState.peopleSize} orang',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to format time string with proper error handling
  String _formatTimeString(String timeString) {
    try {
      final timeParts = timeString.split(':');
      if (timeParts.length == 2) {
        final hour = int.tryParse(timeParts[0]) ?? 0;
        final minute = timeParts[1];
        final ampm = hour < 12 ? 'AM' : 'PM';
        final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        return '$displayHour:$minute $ampm';
      }

      // Fallback to using reservation time from form state
      final hour = _formState.reservationTime.hour;
      final minute = _formState.reservationTime.minute.toString().padLeft(2, '0');
      final ampm = hour < 12 ? 'AM' : 'PM';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      return '$displayHour:$minute $ampm';
    } catch (e) {
      // Ultimate fallback if everything fails
      return 'Tidak ditentukan';
    }
  }

  Widget _buildPreOrderItemsCard() {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.args.menuItems.length,
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DottedDivider(color: AppPallete.neutralColor),
              ),
              itemBuilder: (context, index) {
                final item = widget.args.menuItems[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.menuItem.name,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            if (item.menuItem.description.isNotEmpty)
                              Text(
                                item.menuItem.description,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppPallete.neutralColor.shade600,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        (item.menuItem.price * item.quantity).toIDRFormat(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
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
          _noteController.text.isEmpty
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
                    "Add Special Requests",
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
                              _noteController.text,
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
                        "Edit Requests",
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
    );
  }

  Widget _buildPaymentSummaryCard(int totalPrice) {
    const reservationFee = 5000; // Example reservation fee
    final grandTotal = totalPrice + reservationFee;

    return Container(
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
                'Ringkasan pembayaran',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.args.menuItems.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pre-order Subtotal',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  totalPrice.toIDRFormat(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Biaya reservasi',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                reservationFee.toIDRFormat(),
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
                'Total pembayaran',
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
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppPallete.primaryColor.withAlpha(15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.payment,
                  size: 16,
                  color: AppPallete.primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pembayaran akan diproses setelah reservasi Anda disetujui oleh restoran.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppPallete.primaryColor,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(int totalPrice) {
    const reservationFee = 5000; // Example reservation fee
    final grandTotal = totalPrice + reservationFee;

    return Container(
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
                  // Here you would submit the reservation
                  ref
                      .read(createReservationViewModelProvider.notifier)
                      .createReservation(_formState);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppPallete.primaryColor,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Reserve",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.check_circle_outline,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(int day) {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return days[day - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return months[month - 1];
  }
}
