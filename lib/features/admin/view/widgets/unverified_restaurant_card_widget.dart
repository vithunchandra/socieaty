import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';

class UnverifiedRestaurantCardWidget extends ConsumerWidget {
  final SocieatyRestaurant restaurant;
  final VoidCallback onVerifySuccess;

  const UnverifiedRestaurantCardWidget({
    super.key,
    required this.restaurant,
    required this.onVerifySuccess,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppPallete.neutralColor.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRestaurantImage(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        restaurant.email,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppPallete.neutralColor.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        restaurant.phoneNumber,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppPallete.neutralColor.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            _buildBankInformation(),
            const SizedBox(height: 12),
            _buildThemesList(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showVerifyConfirmationDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPallete.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Verify Restaurant'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 80,
        height: 80,
        color: AppPallete.neutralColor.shade100,
        child: restaurant.profilePictureUrl != null
            ? Image.network(
                restaurant.profilePictureUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.restaurant,
                    size: 32,
                    color: AppPallete.neutralColor.shade400,
                  );
                },
              )
            : Icon(
                Icons.restaurant,
                size: 32,
                color: AppPallete.neutralColor.shade400,
              ),
      ),
    );
  }

  Widget _buildBankInformation() {
    return Row(
      children: [
        Icon(
          Icons.account_balance,
          size: 18,
          color: AppPallete.primaryColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: AppPallete.neutralColor.shade700,
              ),
              children: [
                TextSpan(
                  text: 'Bank: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: restaurant.restaurantData.payoutBank.name),
                const TextSpan(text: ' • '),
                TextSpan(
                  text: 'Account: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: restaurant.restaurantData.accountNumber),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThemesList() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: restaurant.restaurantData.themes.map((theme) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppPallete.primaryColor.withAlpha(16),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppPallete.primaryColor.withAlpha(60),
              width: 1,
            ),
          ),
          child: Text(
            theme.name,
            style: TextStyle(
              fontSize: 12,
              color: AppPallete.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showVerifyConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify Restaurant'),
        content: Text('Are you sure you want to verify "${restaurant.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppPallete.neutralColor.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement the verification logic here
              // Should call the repository to verify the restaurant
              // Then call onVerifySuccess() when done
              onVerifySuccess();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallete.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }
}
