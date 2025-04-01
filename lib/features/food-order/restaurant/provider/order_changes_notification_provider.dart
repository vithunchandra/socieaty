import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/features/food-order/model/food_order_transaction.dart';

part 'order_changes_notification_provider.g.dart';

@Riverpod(keepAlive: true)
class OrderChangesNotification extends _$OrderChangesNotification {
  @override
  FoodOrderTransaction? build() {
    return null;
  }

  void setOrder(FoodOrderTransaction order) {
    state = order;
  }

  void clearOrder() {
    state = null;
  }
}
