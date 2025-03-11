import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/features/food-order/model/food_order_transaction.dart';

part 'new_order_notification_provider.g.dart';

// This provider manages notifications about new orders
// It will be used to refresh the transaction list when a new order is received
@Riverpod(keepAlive: true)
class NewOrderNotification extends _$NewOrderNotification {
  @override
  FoodOrderTransaction? build() {
    // Initially, there is no new order
    return null;
  }

  // Set the latest order
  void setNewOrder(FoodOrderTransaction order) {
    state = order;
  }

  // Reset the state after the UI has been notified
  void resetNotification() {
    state = null;
  }
}
