import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/support-ticket/enum/support_ticket_status_enum.dart';
import 'package:socieaty/shared/models/pagination_query.dart';

part 'get_support_tickets_request_query.freezed.dart';
part 'get_support_tickets_request_query.g.dart';

@freezed
class GetSupportTicketsRequestQuery with _$GetSupportTicketsRequestQuery {
  const factory GetSupportTicketsRequestQuery({
    required PaginationQuery paginationQuery,
    required String? userId,
    required String? searchQuery,
    @SupportTicketStatusConverter() required SupportTicketStatus? status,
  }) = _GetSupportTicketsRequestQuery;

  factory GetSupportTicketsRequestQuery.fromJson(Map<String, dynamic> json) =>
      _$GetSupportTicketsRequestQueryFromJson(json);
}
