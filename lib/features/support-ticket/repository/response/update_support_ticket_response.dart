import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/support-ticket/model/support_ticket.dart';

part 'update_support_ticket_response.freezed.dart';
part 'update_support_ticket_response.g.dart';

@freezed
class UpdateSupportTicketResponse with _$UpdateSupportTicketResponse {
  const factory UpdateSupportTicketResponse({
    required SupportTicket supportTicket,
  }) = _UpdateSupportTicketResponse;

  factory UpdateSupportTicketResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateSupportTicketResponseFromJson(json);
}
