import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/features/menu_item/model/menu_item.dart';
import 'package:socieaty/features/reservation/model/reservation.dart';

class CompletedReservationScreen extends StatefulWidget {
  final Reservation reservation;
  final VoidCallback onBackToHome;
  final VoidCallback onRateRestaurant;

  const CompletedReservationScreen({
    super.key,
    required this.reservation,
    required this.onBackToHome,
    required this.onRateRestaurant,
  });

  @override
  State<CompletedReservationScreen> createState() => _CompletedReservationScreenState();
}

class _CompletedReservationScreenState extends State<CompletedReservationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animationController,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: AppPallete.primaryColor.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: AppPallete.primaryColor,
                  size: 100,
                ),
              ),
            ),
            const SizedBox(height: 32),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'Reservasi Selesai!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppPallete.primaryColor,
                      fontSize: 28,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Anda telah menyelesaikan reservasi. Terima kasih telah menggunakan layanan kami.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppPallete.neutralColor.shade600,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.5),
                end: Offset.zero,
              ).animate(_slideAnimation),
              child: _buildReservationSummaryCard(widget.reservation),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: widget.onRateRestaurant,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPallete.primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Nilai Restoran'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: widget.onBackToHome,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppPallete.primaryColor,
                side: BorderSide(color: AppPallete.primaryColor),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Kembali ke Beranda'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationSummaryCard(Reservation reservation) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('EEEE, d MMMM yyyy');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(30),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reservasi #${reservation.reservationId.substring(0, 8)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: reservation.reservationStatus.getStatusColor().withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  reservation.reservationStatus.name.toUpperCase(),
                  style: TextStyle(
                    color: reservation.reservationStatus.getStatusColor(),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Tanggal', dateFormat.format(reservation.reservationTime)),
          const SizedBox(height: 8),
          _buildDetailRow('Waktu', timeFormat.format(reservation.reservationTime)),
          const SizedBox(height: 8),
          _buildDetailRow('Restoran', reservation.restaurant.name),
          const SizedBox(height: 8),
          _buildDetailRow('Jumlah Orang', '${reservation.peopleSize} orang'),
          if (reservation.menuItems.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.restaurant_menu,
                  color: AppPallete.primaryColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Menu Pesanan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppPallete.neutralColor.shade800,
                  ),
                ),
                const Spacer(),
                Text(
                  '${reservation.menuItems.length} item',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppPallete.neutralColor.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: reservation.menuItems.length > 3 ? 3 : reservation.menuItems.length,
              separatorBuilder: (context, index) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final item = reservation.menuItems[index];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.quantity}x',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppPallete.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.menu.name,
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'Rp ${item.totalPrice}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppPallete.primaryColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                );
              },
            ),
            if (reservation.menuItems.length > 3) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '+ ${reservation.menuItems.length - 3} menu lainnya',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppPallete.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: AppPallete.primaryColor.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Rp ${_calculateTotalPrice(reservation.menuItems)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppPallete.primaryColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  int _calculateTotalPrice(List<MenuItem> items) {
    return items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppPallete.neutralColor.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppPallete.neutralColor.shade800,
          ),
        ),
      ],
    );
  }
}
