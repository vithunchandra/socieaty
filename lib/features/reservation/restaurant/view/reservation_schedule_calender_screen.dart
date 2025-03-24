import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/features/restaurant/model/reservation_config.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:intl/intl.dart';
import 'package:socieaty/features/reservation/model/reservation.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';
import 'package:socieaty/features/customer/model/socieaty_customer.dart';
import 'package:socieaty/core/enums/user_role.enum.dart';
import 'package:socieaty/features/restaurant/model/restaurant_data.dart';
import 'package:socieaty/features/customer/model/customer_data.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socieaty/core/enums/bank.enum.dart';
import 'package:socieaty/features/restaurant/model/restaurant_theme.dart';
import 'package:socieaty/features/menu_item/model/menu_item.dart';

class ReservationScheduleCalenderScreen extends StatefulWidget {
  final ReservationConfig reservationConfig;
  const ReservationScheduleCalenderScreen({super.key, required this.reservationConfig});

  @override
  State<ReservationScheduleCalenderScreen> createState() =>
      _ReservationScheduleCalenderScreenState();
}

class _ReservationScheduleCalenderScreenState extends State<ReservationScheduleCalenderScreen> {
  final EventController eventController = EventController();
  final GlobalKey<DayViewState> dayViewKey = GlobalKey<DayViewState>();
  final DateTime now = DateTime.now();
  late DateTime selectedDate;

  List<Reservation> dummyReservations = [];

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime(now.year, now.month, now.day);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
    ));
    _generateDummyData();
    _loadEvents();
  }

  void _generateDummyData() {
    final int timeLimit = widget.reservationConfig.timeLimit;
    final DateTime today = DateTime(now.year, now.month, now.day);

    // Generate reservations for the next 7 days
    for (int day = 0; day < 7; day++) {
      final DateTime reservationDay = today.add(Duration(days: day));

      // Generate 2-3 reservations per day
      final int reservationsCount = 2 + (day % 2);

      for (int i = 0; i < reservationsCount; i++) {
        // Random hour between 11 AM and 8 PM
        final int startHour = 11 + (i * 2);
        if (startHour > 20) continue; // Don't create reservations after 8 PM

        final DateTime reservationTime = DateTime(
          reservationDay.year,
          reservationDay.month,
          reservationDay.day,
          startHour,
          0,
        );

        final DateTime endTimeEstimation = reservationTime.add(Duration(minutes: timeLimit));

        // Create dummy restaurant with restaurantData
        final restaurant = SocieatyRestaurant(
          id: 'restaurant_$i',
          name: 'Restaurant $i',
          email: 'restaurant$i@example.com',
          phoneNumber: '08123456789',
          profilePictureUrl: 'https://example.com/profile.jpg',
          role: UserRole.restaurant,
          restaurantData: RestaurantData(
            id: 'restaurant_data_$i',
            restaurantBannerUrl: 'https://example.com/banner.jpg',
            location: const LatLng(-6.2088, 106.8456),
            themes: [
              RestaurantTheme(
                id: 1,
                name: 'Casual',
              )
            ],
            payoutBank: BankEnum.bca,
            accountNumber: '1234567890',
            openTime: '08:00',
            closeTime: '22:00',
            isReservationAvailable: true,
          ),
        );

        // Create dummy customer with customerData
        final customer = SocieatyCustomer(
          id: 'customer_${day * 10 + i}',
          name: 'Customer ${day * 10 + i}',
          email: 'customer${day * 10 + i}@example.com',
          phoneNumber: '08123456789',
          profilePictureUrl: 'https://example.com/profile.jpg',
          role: UserRole.customer,
          customerData: CustomerData(
            id: 'customer_data_${day * 10 + i}',
            bio: 'Customer bio',
            wallet: 500000,
          ),
        );

        dummyReservations.add(
          Reservation(
            transactionId: 'trans_${day}_$i',
            serviceType: TransactionServiceType.reservation,
            grossAmount: 150000 * (2 + (i % 4)),
            serviceFee: 15000,
            note: 'Special request for table $i',
            status: TransactionStatus.ongoing,
            restaurant: restaurant,
            customer: customer,
            reservationId: 'res_${day}_$i',
            reservationStatus: ReservationStatus.confirmed,
            reservationTime: reservationTime,
            endTimeEstimation: endTimeEstimation,
            peopleSize: 2 + (i % 4),
            menuItems: <MenuItem>[],
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            updatedAt: DateTime.now(),
            finishedAt: null,
          ),
        );
      }
    }
  }

  void _loadEvents() {
    eventController.removeWhere((element) => true); // Clear existing events

    // Filter reservations for the selected date
    final filteredReservations = dummyReservations.where((reservation) {
      return reservation.reservationTime.year == selectedDate.year &&
          reservation.reservationTime.month == selectedDate.month &&
          reservation.reservationTime.day == selectedDate.day;
    }).toList();

    // Add events to the controller
    for (var reservation in filteredReservations) {
      eventController.add(
        CalendarEventData(
          date: reservation.reservationTime,
          startTime: reservation.reservationTime,
          endTime: reservation.endTimeEstimation,
          title: '${reservation.customer.name} - ${reservation.peopleSize} people',
          description: 'Reservation ID: ${reservation.reservationId}',
          color: AppPallete.primaryColor.shade300,
          event: reservation,
        ),
      );
    }
  }

  void _showReservationDetails(List<CalendarEventData> events) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reservations',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppPallete.primaryColor,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppPallete.neutralColor),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
              const Divider(thickness: 1),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 12),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final reservation = event.event as Reservation;

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(
                            reservation.customer.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.people,
                                      size: 16, color: AppPallete.neutralColor),
                                  const SizedBox(width: 4),
                                  Text('${reservation.peopleSize} people'),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      size: 16, color: AppPallete.neutralColor),
                                  const SizedBox(width: 4),
                                  Text(
                                      '${DateFormat('HH:mm').format(reservation.reservationTime)} - ${DateFormat('HH:mm').format(reservation.endTimeEstimation)}'),
                                ],
                              ),
                              const SizedBox(height: 4),
                              if (reservation.note.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(Icons.note,
                                        size: 16, color: AppPallete.neutralColor),
                                    const SizedBox(width: 4),
                                    Expanded(
                                        child: Text(reservation.note,
                                            maxLines: 1, overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                            ],
                          ),
                          leading: CircleAvatar(
                            backgroundColor: AppPallete.primaryColor,
                            child: Text(
                              reservation.customer.name.substring(0, 1),
                              style:
                                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppPallete.primaryColor.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '₱${reservation.grossAmount}',
                              style: TextStyle(
                                color: AppPallete.primaryColor.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          onTap: () {
                            context.pop();
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppPallete.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppPallete.neutralColor.shade700,
            ),
          ),
          child: child,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _loadEvents();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.primaryColor,
      body: SafeArea(
        child: DayView(
          key: dayViewKey,
          controller: eventController,
          pageTransitionCurve: Curves.easeIn,
          initialDay: selectedDate,
          timeLineBuilder: (date) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Container(
              height: 24,
              alignment: Alignment.center,
              child: Text(
                DateFormat('HH:mm').format(date),
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ),
          headerStyle: HeaderStyle(
            decoration: BoxDecoration(
              color: AppPallete.primaryColor,
            ),
            headerTextStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                ),
            leftIconConfig: const IconDataConfig(
              color: Colors.white,
            ),
            rightIconConfig: const IconDataConfig(
              color: Colors.white,
            ),
          ),
          dateStringBuilder: (date, {secondaryDate}) {
            return "${DateFormat('EEEE').format(date)}, ${DateFormat('dd MMMM yyyy').format(date)}";
          },
          hourIndicatorSettings: HourIndicatorSettings(
            height: 1.0,
            color: AppPallete.neutralColor.shade300,
            offset: 12,
          ),
          heightPerMinute: 1.0,
          startHour: 8,
          endHour: 22,
          onEventTap: (events, date) {
            _showReservationDetails(events);
          },
          onDateLongPress: (date) {
            _selectDate();
          },
          onDateTap: (date) {
            setState(() {
              selectedDate = DateTime(
                date.year,
                date.month,
                date.day,
              );
              _loadEvents();
            });
          },
          liveTimeIndicatorSettings: LiveTimeIndicatorSettings(
            color: AppPallete.secondaryColor,
            offset: 5,
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          showVerticalLine: true,
          showLiveTimeLineInAllDays: true,
          pageViewPhysics: const ClampingScrollPhysics(),
          eventTileBuilder: (date, events, boundary, startDuration, endDuration) {
            if (events.isEmpty) return const SizedBox.shrink();

            return Container(
              decoration: BoxDecoration(
                color: events[0].color,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: events[0].color.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${events.length} reservations',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${events[0].startTime?.hour.toString().padLeft(2, '0') ?? '00'}:${events[0].startTime?.minute.toString().padLeft(2, '0') ?? '00'} - ${events[0].endTime?.hour.toString().padLeft(2, '0') ?? '00'}:${events[0].endTime?.minute.toString().padLeft(2, '0') ?? '00'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: events.length > 3 ? 3 : events.length,
                        itemBuilder: (context, index) {
                          final reservation = events[index].event as Reservation;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      reservation.customer.name.substring(0, 1),
                                      style: TextStyle(
                                        color: AppPallete.primaryColor.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    reservation.customer.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    if (events.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '+${events.length - 3} more',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 9,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    eventController.dispose();
    super.dispose();
  }
}
