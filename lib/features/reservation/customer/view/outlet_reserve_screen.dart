import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/theme/custom_themes/button_theme.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/features/food_menu/model/menu_cart.dart';
import 'package:socieaty/features/food_menu/provider/menu_cart_view_model.dart';
import 'package:socieaty/features/menu_item/model/menu_cart_item.dart';
import 'package:socieaty/features/reservation/customer/view/create_reservation_screen.dart';
import 'package:socieaty/features/reservation/customer/view/reservation_food_selection_screen.dart';
import 'package:socieaty/features/reservation/customer/viewstate/create_reservation_form_state.dart';
import 'package:socieaty/features/restaurant/model/reservation_config.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';
import 'package:socieaty/features/restaurant/provider/get_restaurant_reservation_config_provider.dart';
import 'package:socieaty/shared/widgets/dotted_divider.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class OutletReserveScreen extends ConsumerStatefulWidget {
  final SocieatyRestaurant restaurant;
  const OutletReserveScreen({super.key, required this.restaurant});

  @override
  ConsumerState<OutletReserveScreen> createState() => _OutletReserveScreenState();
}

class _OutletReserveScreenState extends ConsumerState<OutletReserveScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;
  int _selectedGuests = 3;
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  final GlobalKey _sliverKey = GlobalKey();
  double _sliverHeight = 0;
  final List<int> _guestOptions = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  List<MenuCart> _selectedMenuItems = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _measureSliverHeight();
    });
  }

  void _measureSliverHeight() {
    final RenderBox? renderBox = _sliverKey.currentContext?.findRenderObject() as RenderBox?;
    final size = renderBox?.size;
    if (size != null) {
      _sliverHeight = size.height;
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    double collapsedPercentage = _scrollController.offset / _sliverHeight;

    bool newIsCollapsed = collapsedPercentage >= 0.5;

    if (mounted && newIsCollapsed != _isCollapsed) {
      setState(() {
        _isCollapsed = newIsCollapsed;
      });
    }
  }

  void _navigateToFoodSelection() async {
    // Clear any existing menu cart items for this restaurant
    ref.read(menuCartViewModelProvider(widget.restaurant.id).notifier).clearCart();

    // If we have selected menu items, add them to the cart
    if (_selectedMenuItems.isNotEmpty) {
      final cartNotifier = ref.read(menuCartViewModelProvider(widget.restaurant.id).notifier);
      for (final item in _selectedMenuItems) {
        for (int i = 0; i < item.quantity; i++) {
          cartNotifier.addMenuToCart(item.menuItem);
        }
      }
    }

    final result = await context.push(
      '/${widget.restaurant.id}/shop/reserve/food-selection',
      extra: ReservationFoodSelectionScreenArgs(restaurant: widget.restaurant),
    );

    if (result is ReservationFoodSelectionScreenResult) {
      setState(() {
        _selectedMenuItems = result.menuItems;
      });
    } else {
      // If no result was returned, ensure we're using the latest cart state
      setState(() {
        _selectedMenuItems = [];
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reservationConfigAsync =
        ref.watch(getRestaurantReservationConfigProvider(widget.restaurant.restaurantData.id));

    final totalPrice = _selectedMenuItems.isEmpty
        ? 0
        : _selectedMenuItems.fold(0, (sum, item) => sum + item.quantity * item.menuItem.price);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.read(menuCartViewModelProvider(widget.restaurant.id).notifier).clearCart();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: Text(
            _isCollapsed ? 'Booking Meja' : '',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppPallete.neutralColor.shade800, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildHeader(),
            _buildGuestSelection(),
            _buildDateSelection(),
            _buildTimeSlots(reservationConfigAsync),
            _buildFoodMenuSelection(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: () {
                      if (_selectedTime == null) {
                        // Show error for time not selected
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Please select a time slot"),
                            backgroundColor: AppPallete.errorColor,
                          ),
                        );
                        return;
                      }

                      // Convert menu items to the format needed for the form
                      final menuCartItems = _selectedMenuItems
                          .map((menuCart) => MenuCartItem(
                                menuId: menuCart.menuItem.id,
                                quantity: menuCart.quantity,
                              ))
                          .toList();

                      // Create the form state with the current selections
                      final formState = CreateReservationFormState(
                        restaurantId: widget.restaurant.restaurantData.id,
                        reservationTime: DateTime(
                          _selectedDate.year,
                          _selectedDate.month,
                          _selectedDate.day,
                          int.parse(_selectedTime!.split(':')[0]),
                          int.parse(_selectedTime!.split(':')[1]),
                        ),
                        peopleSize: _selectedGuests,
                        note: "",
                        menuItems: menuCartItems,
                      );

                      // Navigate to create reservation screen
                      context.push(
                        '/${widget.restaurant.id}/shop/reserve/create',
                        extra: CreateReservationScreenArgs(
                          formState: formState,
                          restaurant: widget.restaurant,
                          menuItems: _selectedMenuItems,
                          selectedTime: _selectedTime!,
                        ),
                      );
                    },
                    style: CustomButtonStyle.filledButtonStyle.copyWith(
                      backgroundColor: WidgetStateProperty.all(AppPallete.primaryColor),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    child: Text(
                      'Konfirmasi Reservasi',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildFoodMenuSelection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppPallete.neutralColor.shade200.withAlpha(80),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.restaurant_menu, color: AppPallete.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Pre-order Menu',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_selectedMenuItems.isEmpty)
                  _buildEmptyMenuState()
                else
                  _buildSelectedMenuList(),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _navigateToFoodSelection,
                    icon: Icon(
                      _selectedMenuItems.isEmpty ? Icons.add : Icons.edit,
                      color: AppPallete.primaryColor,
                      size: 18,
                    ),
                    label: Text(
                      _selectedMenuItems.isEmpty ? 'Tambahkan Menu' : 'Edit Menu',
                      style: TextStyle(color: AppPallete.primaryColor),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: AppPallete.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyMenuState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppPallete.neutralColor.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppPallete.neutralColor.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_outlined,
            size: 48,
            color: AppPallete.neutralColor.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'Tidak ada menu yang dipilih',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppPallete.neutralColor.shade700,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Pre-order makanan favorit Anda untuk menghemat waktu selama kunjungan Anda',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppPallete.neutralColor.shade600,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedMenuList() {
    final totalPrice = _selectedMenuItems.isEmpty
        ? 0
        : _selectedMenuItems.fold(0, (sum, item) => sum + item.quantity * item.menuItem.price);

    return Column(
      children: [
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
                  'Makanan ini akan disiapkan sebelum Anda datang',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppPallete.primaryColor,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _selectedMenuItems.length,
          separatorBuilder: (context, index) => const Divider(height: 0.5),
          itemBuilder: (context, index) {
            final item = _selectedMenuItems[index];
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
        if (_selectedMenuItems.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: DottedDivider(color: AppPallete.neutralColor),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total harga menu',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                totalPrice.toIDRFormat(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppPallete.primaryColor,
                    ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  SliverToBoxAdapter _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        key: _sliverKey,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking sebuah meja',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppPallete.neutralColor.shade800,
                  ),
            ),
            Row(
              children: [
                Icon(Icons.restaurant, size: 16, color: AppPallete.neutralColor.shade500),
                const SizedBox(width: 4),
                Text(
                  widget.restaurant.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppPallete.neutralColor.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildGuestSelection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppPallete.neutralColor.shade200.withAlpha(80),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.people, color: AppPallete.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Jumlah tamu',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppPallete.neutralColor.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedGuests,
                      icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                      isDense: true,
                      style: Theme.of(context).textTheme.titleMedium,
                      onChanged: (int? value) {
                        if (value != null) {
                          setState(() {
                            _selectedGuests = value;
                          });
                        }
                      },
                      items: _guestOptions.map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildDateSelection() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Generate dates for 7 days starting from today
    final dates = List.generate(7, (index) => today.add(Duration(days: index)));

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppPallete.neutralColor.shade200.withAlpha(80),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: AppPallete.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Pilih tanggal',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 75,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: dates.length,
                    itemBuilder: (context, index) {
                      final date = dates[index];
                      final isSelected = date.day == _selectedDate.day &&
                          date.month == _selectedDate.month &&
                          date.year == _selectedDate.year;

                      return Padding(
                        padding: EdgeInsets.only(right: index < dates.length - 1 ? 8 : 0),
                        child: _buildDateOption(
                          _getDayLabel(date),
                          '${date.day} ${_getMonthString(date.month)}',
                          date,
                          isSelected,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getMonthString(int month) {
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

  String _getDayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (date.year == today.year && date.month == today.month && date.day == today.day) {
      return 'Hari ini';
    } else if (date.year == today.add(const Duration(days: 1)).year &&
        date.month == today.add(const Duration(days: 1)).month &&
        date.day == today.add(const Duration(days: 1)).day) {
      return 'Besok';
    } else {
      const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
      return days[date.weekday - 1];
    }
  }

  Widget _buildDateOption(String label, String date, DateTime dateTime, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = dateTime;
        });
      },
      child: AnimatedContainer(
        width: 80,
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppPallete.primaryColor.shade50 : Colors.white,
          border: Border.all(
            color: isSelected ? AppPallete.primaryColor : AppPallete.neutralColor.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppPallete.primaryColor : AppPallete.neutralColor.shade700,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              date,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected ? AppPallete.primaryColor : AppPallete.neutralColor.shade500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildTimeSlots(AsyncValue<ReservationConfig?> reservationConfigAsync) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppPallete.neutralColor.shade200.withAlpha(80),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time_filled, color: AppPallete.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Slot waktu tersedia',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                reservationConfigAsync.when(
                  data: (config) {
                    List<String> timeSlots = _generateTimeSlots(config, _selectedDate);
                    if (timeSlots.isEmpty) {
                      return _buildEmptyTimeSlotsMessage();
                    }
                    return _buildTimeSlotsGrid(timeSlots);
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: const LoadingIndicatorWidget(size: 36),
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text('Gagal memuat slot waktu reservasi'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlotsGrid(List<String> timeSlots) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: timeSlots.length,
      itemBuilder: (context, index) {
        return _buildTimeSlot(timeSlots[index]);
      },
    );
  }

  Widget _buildTimeSlot(String time) {
    bool isSelected = _selectedTime == time;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTime = time;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppPallete.primaryColor.shade50 : Colors.white,
          border: Border.all(
            color: isSelected ? AppPallete.primaryColor : AppPallete.neutralColor.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppPallete.primaryColor.withAlpha(30),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            time,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppPallete.primaryColor : AppPallete.neutralColor.shade800,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTimeSlotsMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 48,
            color: AppPallete.neutralColor.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada slot waktu tersedia',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppPallete.neutralColor.shade700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Silakan pilih tanggal lain untuk reservasi Anda',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppPallete.neutralColor.shade600,
                ),
          ),
        ],
      ),
    );
  }

  List<String> _generateTimeSlots(ReservationConfig? config, DateTime selectedDate) {
    final openTimeStr = widget.restaurant.restaurantData.openTime;
    final closeTimeStr = widget.restaurant.restaurantData.closeTime;

    final openTimeParts = openTimeStr.split(':');
    final closeTimeParts = closeTimeStr.split(':');

    if (openTimeParts.length < 2 || closeTimeParts.length < 2) {
      return ['12:00', '12:15', '12:30', '12:45', '13:00', '13:15'];
    }

    int openHour = int.tryParse(openTimeParts[0]) ?? 9;
    int openMinute = int.tryParse(openTimeParts[1]) ?? 0;
    int closeHour = int.tryParse(closeTimeParts[0]) ?? 21;
    int closeMinute = int.tryParse(closeTimeParts[1]) ?? 0;

    // Use timeLimit from reservation config if available
    int timeIntervalMinutes = 15; // Default
    if (config != null && config.timeLimit > 0) {
      timeIntervalMinutes = config.timeLimit;
    }

    List<String> slots = [];

    int openTimeInMinutes = openHour * 60 + openMinute;
    int closeTimeInMinutes = closeHour * 60 + closeMinute;

    bool isCrossingMidnight = openTimeInMinutes > closeTimeInMinutes;

    // Check if selected date is today
    final now = DateTime.now();

    bool isToday = selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
    final currentTimeInMinutes = isToday ? now.hour * 60 + now.minute : 0;
    int minutePointer = 0;

    if (isCrossingMidnight) {
      while (minutePointer < 24 * 60) {
        if ((minutePointer > openTimeInMinutes || minutePointer < closeTimeInMinutes) &&
            minutePointer > currentTimeInMinutes) {
          final timeSlot =
              '${(minutePointer % (24 * 60) ~/ 60).toString().padLeft(2, '0')}:${(minutePointer % 60).toString().padLeft(2, '0')}';
          slots.add(timeSlot);
        }
        minutePointer += timeIntervalMinutes;
      }
    } else {
      while (minutePointer < 24 * 60) {
        if ((minutePointer > openTimeInMinutes && minutePointer < closeTimeInMinutes) &&
            minutePointer > currentTimeInMinutes) {
          final timeSlot =
              '${(minutePointer % (24 * 60) ~/ 60).toString().padLeft(2, '0')}:${(minutePointer % 60).toString().padLeft(2, '0')}';
          slots.add(timeSlot);
        }
        minutePointer += timeIntervalMinutes;
      }
    }

    return slots;
  }
}
