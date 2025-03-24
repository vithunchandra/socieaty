import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/theme/custom_themes/button_theme.dart';
import 'package:socieaty/features/restaurant/model/reservation_config.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';
import 'package:socieaty/features/restaurant/provider/get_restaurant_reservation_config_provider.dart';

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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(
          _isCollapsed ? 'Book a table' : '',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppPallete.neutralColor.shade800, size: 20),
          onPressed: () => Navigator.of(context).pop(),
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: () {},
                  style: CustomButtonStyle.filledButtonStyle.copyWith(
                    backgroundColor: WidgetStateProperty.all(AppPallete.primaryColor),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  child: Text(
                    'Proceed to Reservation',
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
              'Book a table',
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
                      'Number of guests',
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
                      'Select date',
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
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  String _getDayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (date.year == today.year && date.month == today.month && date.day == today.day) {
      return 'Today';
    } else if (date.year == today.add(const Duration(days: 1)).year &&
        date.month == today.add(const Duration(days: 1)).month &&
        date.day == today.add(const Duration(days: 1)).day) {
      return 'Tomorrow';
    } else {
      const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
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
                      'Available time slots',
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
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text('Failed to load reservation times'),
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
    final timeParts = time.split(':');
    final hour = timeParts[0];
    final minute = timeParts[1];
    final ampm = int.parse(hour) < 12 ? 'AM' : 'PM';
    final displayHour = int.parse(hour) <= 12 ? hour : (int.parse(hour) - 12).toString();

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$displayHour:$minute",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppPallete.primaryColor : AppPallete.neutralColor.shade800,
                  ),
            ),
            Text(
              ampm,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected ? AppPallete.primaryColor : AppPallete.neutralColor.shade500,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          ],
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
            'No available time slots',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppPallete.neutralColor.shade700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please select another date for your reservation',
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

    int currentTimeInMinutes = openHour * 60 + openMinute;
    int closeTimeInMinutes = closeHour * 60 + closeMinute;

    // Round current time to the next interval
    currentTimeInMinutes = (currentTimeInMinutes ~/ timeIntervalMinutes) * timeIntervalMinutes;

    // Check if selected date is today
    final now = DateTime.now();
    final isToday = selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    // If today, get current time in minutes
    int nowInMinutes = 0;
    if (isToday) {
      nowInMinutes = now.hour * 60 + now.minute;
    }

    while (currentTimeInMinutes < closeTimeInMinutes) {
      int hour = currentTimeInMinutes ~/ 60;
      int minute = currentTimeInMinutes % 60;

      // Skip time slots that have already passed if today
      if (!isToday || currentTimeInMinutes > nowInMinutes) {
        String timeSlot = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        slots.add(timeSlot);
      }

      currentTimeInMinutes += timeIntervalMinutes;
    }

    return slots;
  }
}
