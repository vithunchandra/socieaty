import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/features/transaction/model/food_order_transaction.dart';

class CompletedOrderScreen extends StatelessWidget {
  final FoodOrderTransaction order;
  final VoidCallback onBackToHome;
  final VoidCallback onRateRestaurant;

  const CompletedOrderScreen({
    super.key,
    required this.order,
    required this.onBackToHome,
    required this.onRateRestaurant,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppPallete.primaryColor.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: AppPallete.primaryColor,
                size: 80,
              ),
            ),

            const SizedBox(height: 32),

            Text(
              'Order Completed!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppPallete.primaryColor,
                  ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Your order has been successfully completed. Thank you for using our service.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppPallete.neutralColor.shade600,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Container(
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
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order #${order.id.substring(0, 8)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        (order.grossAmount + order.serviceFee).toIDRFormat(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppPallete.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date',
                        style: TextStyle(
                          color: AppPallete.neutralColor.shade500,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        DateTime.now().toString().substring(0, 16),
                        style: TextStyle(
                          color: AppPallete.neutralColor.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Restaurant',
                        style: TextStyle(
                          color: AppPallete.neutralColor.shade500,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        order.restaurant.name,
                        style: TextStyle(
                          color: AppPallete.neutralColor.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onBackToHome,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPallete.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Back to Home'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onRateRestaurant,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppPallete.primaryColor,
                      side: BorderSide(color: AppPallete.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Rate Restaurant'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
