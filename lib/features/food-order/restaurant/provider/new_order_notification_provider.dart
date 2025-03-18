import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/features/food-order/model/food_order_transaction.dart';

part 'new_order_notification_provider.g.dart';

@Riverpod(keepAlive: true)
class NewOrderNotification extends _$NewOrderNotification {
  @override
  FoodOrderTransaction? build() {
    return null;
  }

  void setNewOrder(FoodOrderTransaction order) {
    state = order;
  }

  void resetNotification() {
    state = null;
  }
}
