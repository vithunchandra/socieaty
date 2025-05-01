import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/admin/view/verify_restaurant_screen.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';

class UnverifiedRestaurantCardWidget extends ConsumerWidget {
  final SocieatyRestaurant restaurant;
  final VoidCallback onUpdateVerificationStatus;

  const UnverifiedRestaurantCardWidget({
    super.key,
    required this.restaurant,
    required this.onUpdateVerificationStatus,
  });

  void _openDetailScreen(BuildContext context) {
    context.push(
      '/admin/restaurant-verification/detail',
      extra: VerifyRestaurantScreenArgs(
        restaurant: restaurant,
        onUpdateVerificationStatus: onUpdateVerificationStatus,
      ),
    );
  }

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
      color: Colors.white,
      child: InkWell(
        onTap: () => _openDetailScreen(context),
        borderRadius: BorderRadius.circular(12),
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
                        const SizedBox(height: 8),
                        _buildThemesList(),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () => _openDetailScreen(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppPallete.primaryColor,
                    side: BorderSide(color: AppPallete.primaryColor),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: const Size(40, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Detail'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 60,
        height: 60,
        color: AppPallete.neutralColor.shade100,
        child: restaurant.profilePictureUrl != null
            ? Image.network(
                restaurant.profilePictureUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.restaurant,
                    size: 28,
                    color: AppPallete.neutralColor.shade400,
                  );
                },
              )
            : Icon(
                Icons.restaurant,
                size: 28,
                color: AppPallete.neutralColor.shade400,
              ),
      ),
    );
  }

  Widget _buildThemesList() {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: restaurant.restaurantData.themes.take(3).map((theme) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppPallete.primaryColor.withAlpha(16),
            borderRadius: BorderRadius.circular(12),
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
}
