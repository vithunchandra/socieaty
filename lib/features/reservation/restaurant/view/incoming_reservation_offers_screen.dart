import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';

class IncomingReservationOffersScreen extends StatelessWidget {
  const IncomingReservationOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Reservation Offers',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: dummyOffers.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final offer = dummyOffers[index];
          return _buildOfferCard(context, offer);
        },
      ),
    );
  }

  Widget _buildOfferCard(BuildContext context, ReservationOffer offer) {
    return Container(
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
                  Icons.access_time,
                  color: AppPallete.primaryColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Requested ${offer.timeAgo}',
                  style: TextStyle(
                    color: AppPallete.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(offer.customerImage),
                      radius: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer.customerName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            offer.phoneNumber,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppPallete.neutralColor.shade500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  context,
                  Icons.calendar_today,
                  'Date',
                  offer.date,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  context,
                  Icons.access_time,
                  'Time',
                  offer.time,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  context,
                  Icons.people,
                  'People',
                  '${offer.peopleCount} persons',
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  context,
                  Icons.comment,
                  'Notes',
                  offer.notes,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Handle decline
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(color: AppPallete.errorColor),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Decline',
                          style: TextStyle(
                            color: AppPallete.errorColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle accept
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: AppPallete.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Accept',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppPallete.neutralColor.shade500,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppPallete.neutralColor.shade500,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ReservationOffer {
  final String customerName;
  final String customerImage;
  final String phoneNumber;
  final String date;
  final String time;
  final int peopleCount;
  final String notes;
  final String timeAgo;

  ReservationOffer({
    required this.customerName,
    required this.customerImage,
    required this.phoneNumber,
    required this.date,
    required this.time,
    required this.peopleCount,
    required this.notes,
    required this.timeAgo,
  });
}

// Dummy data for reservation offers
final List<ReservationOffer> dummyOffers = [
  ReservationOffer(
    customerName: 'Sarah Johnson',
    customerImage: 'https://randomuser.me/api/portraits/women/44.jpg',
    phoneNumber: '123-456-7890',
    date: 'Tomorrow',
    time: '19:00',
    peopleCount: 2,
    notes: 'Anniversary dinner. Would like a table near the window.',
    timeAgo: '10 minutes ago',
  ),
  ReservationOffer(
    customerName: 'Alex Williams',
    customerImage: 'https://randomuser.me/api/portraits/men/32.jpg',
    phoneNumber: '234-567-8901',
    date: 'Aug 24, 2023',
    time: '20:30',
    peopleCount: 4,
    notes: 'Business dinner. Need a quiet table.',
    timeAgo: '25 minutes ago',
  ),
  ReservationOffer(
    customerName: 'Emma Thompson',
    customerImage: 'https://randomuser.me/api/portraits/women/65.jpg',
    phoneNumber: '345-678-9012',
    date: 'Aug 25, 2023',
    time: '18:00',
    peopleCount: 6,
    notes: 'Birthday celebration. Will bring cake.',
    timeAgo: '1 hour ago',
  ),
];
