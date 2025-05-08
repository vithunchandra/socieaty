import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/core/utils/converter.dart';

part 'transaction_chart.freezed.dart';
part 'transaction_chart.g.dart';

@freezed
class TransactionChart with _$TransactionChart {
  const factory TransactionChart({
    required String title,
    @DateTimeConverter() required DateTime date,
    required double totalIncome,
    required int totalTransactions,
  }) = _TransactionChart;

  factory TransactionChart.fromJson(Map<String, dynamic> json) =>
      _$TransactionChartFromJson(json);
}
