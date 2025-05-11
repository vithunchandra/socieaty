import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/reservation/enum/reservation_status_enum.dart';
import 'package:socieaty/features/reservation/model/reservation.dart';
import 'package:socieaty/features/reservation/widgets/reservation_note_widget.dart';
import 'package:socieaty/shared/widgets/dotted_divider.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';
import 'package:socieaty/shared/widgets/profile_picture_widget.dart';
import 'package:socieaty/core/utils/location_handler.dart';

class ActiveReservationView extends ConsumerStatefulWidget {
  final Reservation reservation;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;
  final VoidCallback? onShowQR;
  final VoidCallback? navigateToMapScreen;
  final bool isLoadingLocation;

  const ActiveReservationView({
    super.key,
    required this.reservation,
    this.onCancel,
    this.onReschedule,
    this.onShowQR,
    this.navigateToMapScreen,
    this.isLoadingLocation = false,
  });

  @override
  ConsumerState<ActiveReservationView> createState() => _ActiveReservationViewState();
}

class _ActiveReservationViewState extends ConsumerState<ActiveReservationView> {
  final ScrollController _scrollController = ScrollController();
  bool _isHeaderCollapsed = false;
  String _locationAddress = "Lokasi restoran";

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _getRestaurantAddress();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final double offset = _scrollController.offset;
    final threshold = 100.0;
    final isCollapsed = offset > threshold;

    if (isCollapsed != _isHeaderCollapsed) {
      setState(() {
        _isHeaderCollapsed = isCollapsed;
      });
    }
  }

  void _getRestaurantAddress() async {
    final location = await LocationHandler.getAddressFromLatLng(
        widget.reservation.restaurant.restaurantData.location);
    if (location != null && mounted) {
      setState(() {
        _locationAddress = "${location.street}, ${location.locality}";
      });
    }
  }

  void _showQRCodeDialog() {
    final token = ref.watch(authLocalRepositoryProvider).getToken();
    showDialog(
      context: context,
      builder: (context) => QRCodeDialog(reservation: widget.reservation, token: token!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollUpdateNotification) {
          _handleScroll();
        }
        return false;
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            _buildFixedHeader(widget.reservation),
            _buildContent(widget.reservation),
            _buildActionButtons(widget.reservation),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedHeader(Reservation reservation) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('EEEE, d MMMM yyyy');

    return Container(
      color: AppPallete.primaryColor,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              reservation.reservationStatus.name.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  timeFormat.format(reservation.reservationTime),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppPallete.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  dateFormat.format(reservation.reservationTime),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppPallete.neutralColor.shade600,
                      ),
                ),
                if (reservation.reservationStatus != ReservationStatus.canceled &&
                    reservation.reservationStatus != ReservationStatus.completed) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.access_time,
                        color: AppPallete.primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${reservation.endTimeEstimation.difference(reservation.reservationTime).inHours} jam durasi',
                        style: TextStyle(
                          color: AppPallete.neutralColor.shade600,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Reservation reservation) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
            child: _buildStatusMessage(reservation),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            child: _buildRestaurantSection(reservation),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
            child: _buildReservationDetails(reservation),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            child: _buildLocationCard(reservation),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMessage(Reservation reservation) {
    final Color statusColor = reservation.reservationStatus.getStatusColor();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withAlpha(75)),
      ),
      child: Row(
        children: [
          Icon(
            reservation.reservationStatus.getStatusIcon(),
            color: statusColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reservation.reservationStatus.getStatusName(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    reservation.reservationStatus == ReservationStatus.confirmed
                        ? 'Silakan datang sesuai jadwal'
                        : 'Reservasi sedang diproses',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
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

  Widget _buildRestaurantSection(Reservation reservation) {
    final restaurant = reservation.restaurant;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  ProfilePictureWidget(
                    user: UserConverter.restaurantToUser(restaurant),
                    radius: 28,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppPallete.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.storefront,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppPallete.neutralColor.shade800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: AppPallete.neutralColor.shade600,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${restaurant.restaurantData.openTime} - ${restaurant.restaurantData.closeTime}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppPallete.neutralColor.shade600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: AppPallete.neutralColor.shade600,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _locationAddress,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppPallete.neutralColor.shade600,
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
              Container(
                decoration: BoxDecoration(
                  color: AppPallete.primaryColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: AppPallete.primaryColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '4.5',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppPallete.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const DottedDivider(color: AppPallete.neutralColor),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.isLoadingLocation ? null : widget.navigateToMapScreen,
                  icon: widget.isLoadingLocation
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: LoadingIndicatorWidget(
                            size: 16,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.place, size: 16, color: Colors.white),
                  label: Text(widget.isLoadingLocation ? 'Memuat...' : 'Lihat Lokasi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push('/transaction/message',
                        extra: TransactionConverter.reservationToTransaction(reservation));
                  },
                  icon: const Icon(Icons.chat, size: 16, color: Colors.white),
                  label: const Text('Chat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReservationDetails(Reservation reservation) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppPallete.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Detail Reservasi',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const DottedDivider(color: AppPallete.neutralColor),
          const SizedBox(height: 16),
          _buildDetailRow('Nomor Reservasi', '#${reservation.reservationId.substring(0, 8)}'),
          const SizedBox(height: 12),
          _buildDetailRow('Jumlah Orang', '${reservation.peopleSize} orang'),
          const SizedBox(height: 12),
          _buildDetailRow('Durasi',
              '${reservation.endTimeEstimation.difference(reservation.reservationTime).inHours} jam'),
          if (reservation.note.isNotEmpty) ReservationNoteWidget(note: reservation.note),
          if (reservation.menuItems.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(
                  Icons.restaurant_menu,
                  color: AppPallete.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Menu Pesanan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
            const DottedDivider(color: AppPallete.neutralColor),
            const SizedBox(height: 12),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: reservation.menuItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = reservation.menuItems[index];
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.menu.name,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          if (item.menu.description.isNotEmpty)
                            Text(
                              item.menu.description,
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
                      'Rp ${item.totalPrice}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppPallete.primaryColor,
                          ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppPallete.primaryColor.withAlpha(15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Pesanan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Rp ${reservation.menuItems.calculateTotalPrice()}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppPallete.primaryColor,
                      fontSize: 16,
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

  Widget _buildLocationCard(Reservation reservation) {
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
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppPallete.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Lokasi Restoran',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Lokasi: ${reservation.restaurant.name}",
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: widget.isLoadingLocation || widget.navigateToMapScreen == null
                ? null
                : widget.navigateToMapScreen,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppPallete.primaryColor.withAlpha(127)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              minimumSize: const Size(double.infinity, 48),
            ),
            icon: widget.isLoadingLocation
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: LoadingIndicatorWidget(
                      size: 16,
                      color: AppPallete.primaryColor,
                    ),
                  )
                : Icon(
                    Icons.map_outlined,
                    color: AppPallete.primaryColor,
                    size: 18,
                  ),
            label: Text(
              widget.isLoadingLocation ? 'Memuat...' : 'Lihat di Peta',
              style: TextStyle(
                color: AppPallete.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Reservation reservation) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          if (reservation.reservationStatus == ReservationStatus.confirmed)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showQRCodeDialog,
                    icon: const Icon(Icons.qr_code, size: 18),
                    label: const Text('Tunjukkan QR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPallete.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onReschedule,
                    icon: const Icon(Icons.edit_calendar, size: 18),
                    label: const Text('Atur Ulang'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppPallete.primaryColor,
                      side: BorderSide(color: AppPallete.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else if (reservation.reservationStatus == ReservationStatus.pending)
            OutlinedButton.icon(
              onPressed: widget.onCancel,
              icon: const Icon(Icons.cancel, size: 18),
              label: const Text('Batalkan Reservasi'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppPallete.errorColor,
                side: BorderSide(color: AppPallete.errorColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class QRCodeDialog extends StatelessWidget {
  final String token;
  final Reservation reservation;

  const QRCodeDialog({
    super.key,
    required this.reservation,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    final qrCodeUrl =
        '${AppConstants.socieatyBackendUrl}reservation/${reservation.reservationId}/qr-code';

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'QR Code Reservasi',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppPallete.neutralColor.shade800,
                        ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(
                    Icons.close,
                    color: AppPallete.neutralColor.shade600,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const DottedDivider(color: AppPallete.neutralColor),
            const SizedBox(height: 24),
            Container(
              width: 250,
              height: 250,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Image.network(
                headers: {
                  'Authorization': 'Bearer $token',
                },
                qrCodeUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: AppPallete.primaryColor,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppPallete.errorColor,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Gagal memuat QR Code',
                        style: TextStyle(
                          color: AppPallete.errorColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tunjukkan QR Code ini kepada staf restoran saat kedatangan',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppPallete.neutralColor.shade600,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPallete.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
