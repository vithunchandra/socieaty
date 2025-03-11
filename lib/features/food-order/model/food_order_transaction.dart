import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/customer/model/socieaty_customer.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';
import 'package:socieaty/features/food-order/model/food_order_menu_item.dart';

part 'food_order_transaction.freezed.dart';
part 'food_order_transaction.g.dart';

@freezed
class FoodOrderTransaction with _$FoodOrderTransaction {
  const factory FoodOrderTransaction({
    required String transactionId,
    required String orderId,
    @TransactionServiceTypeConverter() required TransactionServiceType serviceType,
    required int grossAmount,
    required int serviceFee,
    @TransactionStatusConverter() required TransactionStatus status,
    @FoodOrderStatusConverter() required FoodOrderStatus foodOrderStatus,
    required SocieatyRestaurant restaurant,
    required SocieatyCustomer customer,
    required List<FoodOrderMenuItem> menuItems,
    required String note,
  }) = _FoodOrderTransaction;

  factory FoodOrderTransaction.fromJson(Map<String, dynamic> json) =>
      _$FoodOrderTransactionFromJson(json);
}
