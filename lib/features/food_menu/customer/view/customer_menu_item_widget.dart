import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/features/food_menu/model/food_menu.dart';

class CustomerMenuItemWidget extends ConsumerStatefulWidget {
  final FoodMenu restaurantMenu;
  const CustomerMenuItemWidget({super.key, required this.restaurantMenu});

  @override
  ConsumerState<CustomerMenuItemWidget> createState() => _CustomerMenuItemWidgetState();
}

class _CustomerMenuItemWidgetState extends ConsumerState<CustomerMenuItemWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.restaurantMenu.name.toCapitalized(),
                      style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 8),
                  Text(
                    widget.restaurantMenu.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12),
                  Text("Rp ${widget.restaurantMenu.price.toIDRFormat()}",
                      style: Theme.of(context).textTheme.titleSmall)
                ],
              ),
            ),
            SizedBox(width: 24),
            Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      widget.restaurantMenu.pictureUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, color: Colors.grey[400], size: 24),
                                SizedBox(height: 4),
                                Text(
                                  'Image not found',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  bottom: -20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SizedBox(
                      width: 100,
                      height: 40,
                      child: FilledButton(
                        onPressed: () {},
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Text("Edit"),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
