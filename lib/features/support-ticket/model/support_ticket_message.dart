import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';

part 'support_ticket_message.freezed.dart';
part 'support_ticket_message.g.dart';

@freezed
class SupportTicketMessage with _$SupportTicketMessage {
  const factory SupportTicketMessage({
    required String id,
    required String supportTicketId,
    required String message,
    required SocieatyUser user,
    @DateTimeConverter() required DateTime createdAt,
  }) = _SupportTicketMessage;

  factory SupportTicketMessage.fromJson(Map<String, dynamic> json) =>
      _$SupportTicketMessageFromJson(json);
}
