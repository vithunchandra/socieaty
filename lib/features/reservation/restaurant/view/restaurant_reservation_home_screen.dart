import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:table_calendar/table_calendar.dart';

class RestaurantReservationHomeScreen extends StatefulWidget {
  const RestaurantReservationHomeScreen({super.key});

  @override
  State<RestaurantReservationHomeScreen> createState() => _RestaurantReservationHomeScreenState();
}

class _RestaurantReservationHomeScreenState extends State<RestaurantReservationHomeScreen> {
  bool _isReservationEnabled = true;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.neutralColor.shade50,
      appBar: AppBar(
        title: Text(
          'Reservation Management',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReservationToggleCard(),
            const SizedBox(height: 16),
            _buildCalendarSection(),
            const SizedBox(height: 16),
            _buildTodayReservationsSection(),
            const SizedBox(height: 16),
            _buildConfigurationSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to configuration screen
        },
        backgroundColor: AppPallete.primaryColor,
        icon: const Icon(Icons.settings),
        label: const Text('Configure'),
      ),
    );
  }

  Widget _buildReservationToggleCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppPallete.neutralColor.shade200.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reservation Service',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isReservationEnabled
                      ? 'Your restaurant is currently accepting reservations'
                      : 'Your restaurant is not accepting reservations',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppPallete.neutralColor.shade500,
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isReservationEnabled,
            onChanged: (value) {
              setState(() {
                _isReservationEnabled = value;
              });
            },
            activeColor: AppPallete.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppPallete.neutralColor.shade200.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Reservation Calendar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: true,
              formatButtonDecoration: BoxDecoration(
                color: AppPallete.primaryColor.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              formatButtonTextStyle: TextStyle(
                color: AppPallete.primaryColor,
              ),
              titleTextStyle: Theme.of(context).textTheme.titleMedium!,
            ),
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: AppPallete.primaryColor,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppPallete.primaryColor.shade300,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: AppPallete.successColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayReservationsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppPallete.neutralColor.shade200.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppPallete.primaryColor.withAlpha(25),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event,
                  color: AppPallete.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Today\'s Reservations',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppPallete.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          // Sample reservation items
          _buildReservationItem(
            time: '09:30',
            customerName: 'John Doe',
            peopleCount: 2,
            status: 'Confirmed',
          ),
          Divider(height: 1, color: AppPallete.neutralColor.shade200),
          _buildReservationItem(
            time: '13:00',
            customerName: 'Jane Smith',
            peopleCount: 4,
            status: 'Pending',
          ),
          Divider(height: 1, color: AppPallete.neutralColor.shade200),
          _buildReservationItem(
            time: '19:30',
            customerName: 'Robert Johnson',
            peopleCount: 6,
            status: 'Confirmed',
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: TextButton(
                onPressed: () {
                  // TODO: Navigate to detailed reservations page
                },
                child: Text(
                  'View All Reservations',
                  style: TextStyle(
                    color: AppPallete.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationItem({
    required String time,
    required String customerName,
    required int peopleCount,
    required String status,
  }) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'confirmed':
        statusColor = AppPallete.successColor;
        break;
      case 'pending':
        statusColor = AppPallete.warningColor;
        break;
      case 'cancelled':
        statusColor = AppPallete.errorColor;
        break;
      default:
        statusColor = AppPallete.infoColor;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppPallete.primaryColor.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                time,
                style: TextStyle(
                  color: AppPallete.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName,
                  style:
                      Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '$peopleCount people',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppPallete.neutralColor.shade500,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppPallete.neutralColor.shade200.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Configuration',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildConfigItem(
            icon: Icons.people,
            title: 'Maximum People',
            value: '8 per reservation',
          ),
          _buildConfigItem(
            icon: Icons.attach_money,
            title: 'Minimum Cost',
            value: 'Rp 50,000 per person',
          ),
          _buildConfigItem(
            icon: Icons.timer,
            title: 'Time Limit',
            value: '2 hours',
          ),
          _buildConfigItem(
            icon: Icons.category,
            title: 'Facilities',
            value: 'Wi-Fi, Smoking Area, Private Room',
          ),
        ],
      ),
    );
  }

  Widget _buildConfigItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppPallete.primaryColor.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppPallete.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppPallete.neutralColor.shade500,
                      ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
