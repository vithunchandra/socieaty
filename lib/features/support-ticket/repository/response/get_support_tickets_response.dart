import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/support-ticket/model/support_ticket.dart';
import 'package:socieaty/shared/models/pagination.dart';

part 'get_support_tickets_response.freezed.dart';
part 'get_support_tickets_response.g.dart';

@freezed
class GetSupportTicketsResponse with _$GetSupportTicketsResponse {
  const factory GetSupportTicketsResponse({
    required List<SupportTicket> items,
    required Pagination pagination,
  }) = _GetSupportTicketsResponse;

  factory GetSupportTicketsResponse.fromJson(Map<String, dynamic> json) =>
      _$GetSupportTicketsResponseFromJson(json);
}
