import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/customer/model/socieaty_customer.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
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
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
}
