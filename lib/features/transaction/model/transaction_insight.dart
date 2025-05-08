import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_insight.freezed.dart';
part 'transaction_insight.g.dart';

@freezed
class TransactionInsight with _$TransactionInsight {
  const factory TransactionInsight({
    required int totalIncome,
    required int totalFailedTransactions,
    required int totalSuccessTransactions,
    required int totalFoodOrderTransactions,
    required int totalReservationTransactions,
  }) = _TransactionInsight;

  factory TransactionInsight.fromJson(Map<String, dynamic> json) =>
      _$TransactionInsightFromJson(json);
}
