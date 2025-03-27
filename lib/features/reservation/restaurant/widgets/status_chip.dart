import 'package:flutter/material.dart';
import 'package:socieaty/features/reservation/enum/reservation_status_enum.dart';

Widget getStatusChip(ReservationStatus status) {
  Color backgroundColor;
  Color textColor;
  String label;

  switch (status) {
    case ReservationStatus.pending:
      backgroundColor = Colors.amber.shade50;
      textColor = Colors.amber.shade800;
      label = 'Pending';
      break;
    case ReservationStatus.confirmed:
      backgroundColor = Colors.blue.shade50;
      textColor = Colors.blue.shade700;
      label = 'Confirmed';
      break;
    case ReservationStatus.completed:
      backgroundColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
      label = 'Completed';
      break;
    case ReservationStatus.cancelled:
      backgroundColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
      label = 'Cancelled';
      break;
    case ReservationStatus.rejected:
      backgroundColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
      label = 'Rejected';
      break;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    ),
  );
}
