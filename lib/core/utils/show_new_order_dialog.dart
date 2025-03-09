import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:socieaty/features/transaction/model/food_order_transaction.dart';
import 'package:socieaty/main.dart';
import 'package:socieaty/core/utils/color_extension.dart';

void showNewOrderDialog(FoodOrderTransaction order) {
  // Optional: Add vibration to notify without being too intrusive
  HapticFeedback.mediumImpact();

  // Calculate total
  final int total = order.grossAmount + order.serviceFee;

  // Use navigatorKey to show dialog without context
  if (rootNavigatorKey.currentState != null && rootNavigatorKey.currentContext != null) {
    showDialog(
      context: rootNavigatorKey.currentContext!,
      barrierDismissible: true, // Allow dismissing by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacitySafe(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.restaurant,
                      color: Colors.green,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'New Order Received',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 10),
                _buildInfoRow('Order ID', order.id),
                _buildInfoRow('Service', order.serviceType.toString().split('.').last),
                _buildInfoRow('Total', '\$$total'),
                _buildInfoRow('Status', order.status.toString().split('.').last),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Dismiss'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        // Add any additional action here if needed
                        Navigator.of(context).pop();
                      },
                      child: const Text('View Details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _buildInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
