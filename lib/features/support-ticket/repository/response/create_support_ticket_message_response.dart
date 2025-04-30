import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/support-ticket/model/support_ticket_message.dart';

part 'create_support_ticket_message_response.freezed.dart';
part 'create_support_ticket_message_response.g.dart';

@freezed
class CreateSupportTicketMessageResponse with _$CreateSupportTicketMessageResponse {
  const factory CreateSupportTicketMessageResponse({
    required SupportTicketMessage supportTicketMessage,
  }) = _CreateSupportTicketMessageResponse;

  factory CreateSupportTicketMessageResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateSupportTicketMessageResponseFromJson(json);
}
