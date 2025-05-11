import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/reservation/enum/reservation_status_enum.dart';
import 'package:socieaty/features/restaurant/model/reservation_config.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:intl/intl.dart';
import 'package:socieaty/features/reservation/model/reservation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/features/reservation/provider/get_reservations_provider.dart';
import 'package:socieaty/features/reservation/repository/request/get_reservations_query.dart';
import 'package:socieaty/features/reservation/repository/responses/get_reservations_response.dart';
import 'package:socieaty/shared/widgets/profile_picture_widget.dart';
import 'package:socieaty/features/reservation/restaurant/widgets/reservation_card.dart';

class ReservationScheduleCalenderScreen extends ConsumerStatefulWidget {
  final ReservationConfig reservationConfig;
  const ReservationScheduleCalenderScreen({super.key, required this.reservationConfig});

  @override
  ConsumerState<ReservationScheduleCalenderScreen> createState() =>
      _ReservationScheduleCalenderScreenState();
}

class _ReservationScheduleCalenderScreenState
    extends ConsumerState<ReservationScheduleCalenderScreen> {
  final EventController eventController = EventController();
  final GlobalKey<DayViewState> dayViewKey = GlobalKey<DayViewState>();
  final DateTime now = DateTime.now();
  late DateTime selectedDate;

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime(now.year, now.month, now.day);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
    ));
    _fetchReservations();
  }

  Future<void> _fetchReservations() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      debugPrint('date: ${selectedDate.toString()}');

      final query = GetReservationsQuery(
        restaurantId: widget.reservationConfig.restaurantId,
        reservationStatus: [
          ReservationStatus.confirmed,
          ReservationStatus.dining,
          ReservationStatus.completed,
        ],
        reservationTime: selectedDate,
      );

      final reservationsResponse = await ref.read(getReservationsProvider(query).future);
      debugPrint('reservations: ${reservationsResponse.toString()}');
      _loadEvents(reservationsResponse);
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _loadEvents(GetReservationsResponse response) {
    debugPrint('date: ${selectedDate.toString()}');
    eventController.removeWhere((element) => true); // Clear existing events

    final reservations = response.reservations ?? [];
    debugPrint('reservations: ${reservations.toString()}');

    // Group reservations by time
    final Map<String, List<Reservation>> groupedReservations = {};

    for (var reservation in reservations) {
      // Create a key based on hour and minute only
      final timeKey = '${reservation.reservationTime.hour}:${reservation.reservationTime.minute}';

      if (!groupedReservations.containsKey(timeKey)) {
        groupedReservations[timeKey] = [];
      }

      groupedReservations[timeKey]!.add(reservation);
    }

    // Add grouped events to the controller
    groupedReservations.forEach((timeKey, reservationList) {
      // Calculate total people
      int totalPeople = 0;
      DateTime? startTime;
      DateTime? endTime;

      for (var reservation in reservationList) {
        totalPeople += reservation.peopleSize;

        // Set start time to the earliest reservation time
        if (startTime == null || reservation.reservationTime.isBefore(startTime)) {
          startTime = reservation.reservationTime;
        }

        // Set end time to the latest end time
        if (endTime == null || reservation.endTimeEstimation.isAfter(endTime)) {
          endTime = reservation.endTimeEstimation;
        }
      }

      // Start and end time for the event
      startTime = startTime ?? DateTime.now();
      endTime = endTime ?? startTime.add(const Duration(hours: 2));

      debugPrint(
          'Adding grouped event for ${reservationList.length} reservations at time: $startTime, total people: $totalPeople');

      eventController.add(
        CalendarEventData(
          date: startTime,
          startTime: startTime,
          endTime: endTime,
          title: '${reservationList.length} reservations - $totalPeople people',
          description: 'Group of ${reservationList.length} reservations',
          color: AppPallete.primaryColor.shade300,
          event: reservationList, // Store the full list for details view
        ),
      );
    });
  }

  void _showReservationDetails(List<CalendarEventData> events) {
    if (events.isEmpty) return;

    final eventData = events[0];
    final List<Reservation> reservations = eventData.event as List<Reservation>;

    // Create the query for the selected date
    final query = GetReservationsQuery(
      restaurantId: widget.reservationConfig.restaurantId,
      reservationStatus: [
        ReservationStatus.confirmed,
        ReservationStatus.dining,
        ReservationStatus.completed,
      ],
      reservationTime: selectedDate,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ReservationDetailsSheet(
          eventData: eventData,
          originalReservations: reservations,
          query: query,
          ref: ref,
          onRefresh: () {
            ref.invalidate(getReservationsProvider(query));
          },
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
      });
      _fetchReservations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.primaryColor,
      body: SafeArea(
        child: Stack(
          children: [
            DayView(
              key: dayViewKey,
              controller: eventController,
              pageTransitionCurve: Curves.easeIn,
              initialDay: selectedDate,
              onPageChange: (date, _) {
                // This gets called when using the chevron buttons
                if (date.year != selectedDate.year ||
                    date.month != selectedDate.month ||
                    date.day != selectedDate.day) {
                  setState(() {
                    selectedDate = DateTime(date.year, date.month, date.day);
                  });
                  _fetchReservations();
                }
              },
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
                });
                _fetchReservations();
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
                debugPrint('events: ${events.length}');
                if (events.isEmpty) return const SizedBox.shrink();

                final event = events[0];
                final List<Reservation> reservations = event.event as List<Reservation>;

                return ReservationEventCard(
                  event: event,
                  reservations: reservations,
                );
              },
            ),
            if (isLoading)
              Container(
                color: Colors.black.withAlpha(100),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            if (errorMessage != null)
              Container(
                color: Colors.black.withAlpha(100),
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Gagal memuat reservasi',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              errorMessage = null;
                            });
                            _fetchReservations();
                          },
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
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

class ReservationEventCard extends StatelessWidget {
  final CalendarEventData event;
  final List<Reservation> reservations;

  const ReservationEventCard({
    super.key,
    required this.event,
    required this.reservations,
  });

  @override
  Widget build(BuildContext context) {
    int totalPeople = 0;
    for (var reservation in reservations) {
      totalPeople += reservation.peopleSize;
    }

    return Container(
      decoration: BoxDecoration(
        color: event.color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: event.color.withAlpha(80),
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
                    color: Colors.white.withAlpha(80),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${reservations.length} reservasi',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(80),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.people,
                        size: 8,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '$totalPeople',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '${event.startTime?.hour.toString().padLeft(2, '0') ?? '00'}:${event.startTime?.minute.toString().padLeft(2, '0') ?? '00'} - ${event.endTime?.hour.toString().padLeft(2, '0') ?? '00'}:${event.endTime?.minute.toString().padLeft(2, '0') ?? '00'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Expanded(
              child: ListView.separated(
                itemCount: reservations.length,
                scrollDirection: Axis.horizontal,
                separatorBuilder: (context, index) => const SizedBox(width: 4),
                itemBuilder: (context, index) {
                  final reservation = reservations[index];
                  return ProfilePictureWidget(
                    user: UserConverter.customerToUser(reservation.customer),
                    radius: 16,
                  );
                },
              ),
            ),
            if (reservations.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'Tap untuk melihat detail',
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
  }
}

class _ReservationDetailsSheet extends ConsumerStatefulWidget {
  final CalendarEventData eventData;
  final List<Reservation> originalReservations;
  final GetReservationsQuery query;
  final WidgetRef ref;
  final VoidCallback onRefresh;

  const _ReservationDetailsSheet({
    required this.eventData,
    required this.originalReservations,
    required this.query,
    required this.ref,
    required this.onRefresh,
  });

  @override
  ConsumerState<_ReservationDetailsSheet> createState() => _ReservationDetailsSheetState();
}

class _ReservationDetailsSheetState extends ConsumerState<_ReservationDetailsSheet> {
  Future<void> _handleReservationUpdate(Reservation updatedReservation) async {
    // Invalidate the provider to refresh data
    widget.onRefresh();
  }

  // Filter reservations to match the time slot of the original event
  List<Reservation> _filterReservationsByTimeSlot(List<Reservation> allReservations) {
    if (widget.originalReservations.isEmpty) return [];

    // Get the hour and minute of the event's start time (the time slot)
    final eventStartHour = widget.eventData.startTime!.hour;
    final eventStartMinute = widget.eventData.startTime!.minute;

    // Filter reservations to only those matching the time slot
    return allReservations.where((reservation) {
      return reservation.reservationTime.hour == eventStartHour &&
          reservation.reservationTime.minute == eventStartMinute;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider to automatically update when data changes
    final reservationsAsync = ref.watch(getReservationsProvider(widget.query));

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(50),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppPallete.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('HH:mm').format(widget.eventData.startTime!),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${widget.originalReservations.length} Reservasi',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppPallete.neutralColor),
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: reservationsAsync.when(
                  data: (response) {
                    final allReservations = response.reservations ?? [];
                    final filteredReservations = _filterReservationsByTimeSlot(allReservations);

                    return filteredReservations.isEmpty
                        ? const Center(
                            child: Text(
                              'Tidak ada reservasi untuk waktu ini',
                              style: TextStyle(color: AppPallete.neutralColor),
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredReservations.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              return ReservationCard(
                                reservation: filteredReservations[index],
                                onUpdatedReservation: (updatedReservation) async {
                                  // Refresh provider
                                  await _handleReservationUpdate(updatedReservation);
                                },
                              );
                            },
                          );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stackTrace) => Center(
                    child: Text(
                      'Gagal memuat reservasi: $error',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
