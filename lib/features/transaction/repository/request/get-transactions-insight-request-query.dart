import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/core/utils/converter.dart';

part 'get-transactions-insight-request-query.freezed.dart';
part 'get-transactions-insight-request-query.g.dart';

@freezed
class GetTransactionsInsightRequestQuery with _$GetTransactionsInsightRequestQuery {
  const factory GetTransactionsInsightRequestQuery({
    @Default(null) String? restaurantId,
    @DateTimeConverter() required DateTime rangeStartDate,
    @DateTimeConverter() required DateTime rangeEndDate,
    @Default(null) TransactionServiceType? serviceType,
  }) = _GetTransactionsInsightRequestQuery;

  factory GetTransactionsInsightRequestQuery.fromJson(Map<String, dynamic> json) =>
      _$GetTransactionsInsightRequestQueryFromJson(json);
}
