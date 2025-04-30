import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/support-ticket/model/support_ticket.dart';

part 'get_support_ticket_response.freezed.dart';
part 'get_support_ticket_response.g.dart';

@freezed
class GetSupportTicketResponse with _$GetSupportTicketResponse {
  const factory GetSupportTicketResponse({
    required SupportTicket supportTicket,
  }) = _GetSupportTicketResponse;

  factory GetSupportTicketResponse.fromJson(Map<String, dynamic> json) =>
      _$GetSupportTicketResponseFromJson(json);
}
