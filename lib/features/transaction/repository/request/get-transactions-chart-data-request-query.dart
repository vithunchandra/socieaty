import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/core/enums/time_scale.dart';
import 'package:socieaty/core/utils/converter.dart';

part 'get-transactions-chart-data-request-query.freezed.dart';
part 'get-transactions-chart-data-request-query.g.dart';

@freezed
class GetTransactionsChartDataRequestQuery with _$GetTransactionsChartDataRequestQuery {
  const factory GetTransactionsChartDataRequestQuery({
    @Default(null) String? restaurantId,
    @TimeScaleConverter() required TimeScale timeScale,
    @DateTimeConverter() required DateTime rangeStartDate,
    @DateTimeConverter() required DateTime rangeEndDate,
  }) = _GetTransactionsChartDataRequestQuery;

  factory GetTransactionsChartDataRequestQuery.fromJson(Map<String, dynamic> json) =>
      _$GetTransactionsChartDataRequestQueryFromJson(json);
}
