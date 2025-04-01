import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/reservation/enum/reservation_status_enum.dart';

Widget getStatusChip(ReservationStatus status) {
  Color bgColor = Colors.grey;
  Color textColor = Colors.white;
  String label = '';

  switch (status) {
    case ReservationStatus.pending:
      bgColor = Colors.orange;
      textColor = Colors.white;
      label = 'Pending';
      break;
    case ReservationStatus.confirmed:
      bgColor = AppPallete.infoColor;
      textColor = Colors.white;
      label = 'Confirmed';
      break;
    case ReservationStatus.dining:
      bgColor = AppPallete.primaryColor;
      textColor = Colors.white;
      label = 'Dining';
      break;
    case ReservationStatus.completed:
      bgColor = AppPallete.successColor;
      textColor = Colors.white;
      label = 'Completed';
      break;
    case ReservationStatus.rejected:
      bgColor = AppPallete.errorColor;
      textColor = Colors.white;
      label = 'Rejected';
      break;
    case ReservationStatus.canceled:
      bgColor = Colors.red.shade300;
      textColor = Colors.white;
      label = 'Cancelled';
      break;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: textColor,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
