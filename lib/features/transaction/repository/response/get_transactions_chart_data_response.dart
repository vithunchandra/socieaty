import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/transaction/model/transaction_chart.dart';

part 'get_transactions_chart_data_response.freezed.dart';
part 'get_transactions_chart_data_response.g.dart';

@freezed
class GetTransactionsChartDataResponse with _$GetTransactionsChartDataResponse {
  const factory GetTransactionsChartDataResponse({
    required List<TransactionChart> chartData,
  }) = _GetTransactionsChartDataResponse;

  factory GetTransactionsChartDataResponse.fromJson(Map<String, dynamic> json) =>
      _$GetTransactionsChartDataResponseFromJson(json);
}
