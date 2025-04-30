import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/support-ticket/model/support_ticket.dart';

part 'create_support_ticket_response.freezed.dart';
part 'create_support_ticket_response.g.dart';

@freezed
class CreateSupportTicketResponse with _$CreateSupportTicketResponse {
  const factory CreateSupportTicketResponse({
    required SupportTicket supportTicket,
  }) = _CreateSupportTicketResponse;

  factory CreateSupportTicketResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateSupportTicketResponseFromJson(json);
}
