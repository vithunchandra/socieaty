import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/features/transaction/model/transaction_data.dart';
import 'package:socieaty/shared/widgets/profile_picture_widget.dart';
import 'package:socieaty/features/reservation/restaurant/widgets/reservation_details_sheet.dart';
import 'package:socieaty/features/food-order/restaurant/widgets/order_details_sheet.dart';

class TransactionCardWidget extends StatelessWidget {
  final TransactionData transaction;

  const TransactionCardWidget({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd MMM yyyy, HH:mm');
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        _showTransactionDetailsSheet(context);
      },
      child: Card(
        elevation: 2,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ProfilePictureWidget(
                    user: UserConverter.customerToUser(transaction.customer),
                    radius: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                transaction.customer.name,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _buildStatusBadge(context),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          transaction.restaurant.name,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppPallete.neutralColor.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildServiceTypeBadge(context),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        transaction.grossAmount.toIDRFormat(),
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppPallete.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormatter.format(transaction.createdAt),
                        style: textTheme.bodySmall?.copyWith(
                          color: AppPallete.neutralColor.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTransactionDetailsSheet(BuildContext context) {
    if (transaction.serviceType == TransactionServiceType.reservation) {
      if (transaction.reservationData != null) {
        final reservation = TransactionDataConverter.transactionDataToReservation(transaction);
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.85,
            expand: false,
            builder: (context, scrollController) => ReservationDetailsSheet(
              reservation: reservation,
              scrollController: scrollController,
              isActionEnabled: false,
            ),
          ),
        );
      }
    } else if (transaction.serviceType == TransactionServiceType.foodOrder) {
      if (transaction.foodOrderData != null) {
        final foodOrder = TransactionDataConverter.transactionDataToFoodOrder(transaction);
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.85,
            expand: false,
            builder: (context, scrollController) => OrderDetailsSheet(
              order: foodOrder,
              scrollController: scrollController,
              statusFilter: const [],
              isActionEnabled: false,
            ),
          ),
        );
      }
    }
  }

  Widget _buildStatusBadge(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    Color backgroundColor;
    Color textColor;
    String label;

    switch (transaction.status) {
      case TransactionStatus.success:
        backgroundColor = AppPallete.successColor.withAlpha(30);
        textColor = AppPallete.successColor;
        label = 'Success';
        break;
      case TransactionStatus.failed:
        backgroundColor = AppPallete.errorColor.withAlpha(30);
        textColor = AppPallete.errorColor;
        label = 'Failed';
        break;
      case TransactionStatus.ongoing:
        backgroundColor = AppPallete.infoColor.withAlpha(30);
        textColor = AppPallete.infoColor;
        label = 'Ongoing';
        break;
      case TransactionStatus.refunded:
        backgroundColor = AppPallete.warningColor.withAlpha(30);
        textColor = AppPallete.warningColor;
        label = 'Refunded';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildServiceTypeBadge(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isReservation = transaction.serviceType == TransactionServiceType.reservation;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isReservation
            ? AppPallete.successColor.withAlpha(30)
            : AppPallete.secondaryColor.withAlpha(30),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isReservation ? Icons.calendar_month : Icons.restaurant,
            size: 14,
            color: isReservation ? AppPallete.successColor : AppPallete.secondaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            isReservation ? 'Reservasi' : 'Pesanan Makanan',
            style: textTheme.bodySmall?.copyWith(
              color: isReservation ? AppPallete.successColor : AppPallete.secondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
