import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/customer/model/socieaty_customer.dart';
import 'package:socieaty/features/food-order/model/food_order_data.dart';
import 'package:socieaty/features/reservation/model/reservation_data.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';

part 'transaction_data.freezed.dart';
part 'transaction_data.g.dart';

@freezed
class TransactionData with _$TransactionData {
  const factory TransactionData({
    required String transactionId,
    @TransactionServiceTypeConverter() required TransactionServiceType serviceType,
    required int grossAmount,
    required int netAmount,
    required int refundAmount,
    required int serviceFee,
    required String note,
    @TransactionStatusConverter() required TransactionStatus status,
    required SocieatyRestaurant restaurant,
    required SocieatyCustomer customer,
    @DateTimeConverter() required DateTime createdAt,
    @DateTimeConverter() required DateTime updatedAt,
    @DateTimeConverter() required DateTime? finishedAt,
    @Default(null) ReservationData? reservationData,
    @Default(null) FoodOrderData? foodOrderData,
  }) = _TransactionData;

  factory TransactionData.fromJson(Map<String, dynamic> json) => _$TransactionDataFromJson(json);
}