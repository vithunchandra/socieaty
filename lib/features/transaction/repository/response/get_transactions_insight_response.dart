import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/transaction/model/transaction_insight.dart';

part 'get_transactions_insight_response.freezed.dart';
part 'get_transactions_insight_response.g.dart';

@freezed
class GetTransactionsInsightResponse with _$GetTransactionsInsightResponse {
  const factory GetTransactionsInsightResponse({
    required TransactionInsight transactionInsight,
  }) = _GetTransactionsInsightResponse;

  factory GetTransactionsInsightResponse.fromJson(Map<String, dynamic> json) =>
      _$GetTransactionsInsightResponseFromJson(json);
}
