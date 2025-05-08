
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/transaction/model/transaction_data.dart';
import 'package:socieaty/shared/models/pagination.dart';

part 'paginate_transactions_response.freezed.dart';
part 'paginate_transactions_response.g.dart';

@freezed
class PaginateTransactionsResponse with _$PaginateTransactionsResponse {
  const factory PaginateTransactionsResponse({
    required List<TransactionData> items,
    required Pagination pagination,
  }) = _PaginateTransactionsResponse;

  factory PaginateTransactionsResponse.fromJson(Map<String, dynamic> json) =>
      _$PaginateTransactionsResponseFromJson(json);
}
