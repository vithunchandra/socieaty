import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/support-ticket/enum/support_ticket_status_enum.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';

part 'support_ticket.freezed.dart';
part 'support_ticket.g.dart';

@freezed
class SupportTicket with _$SupportTicket {
  const factory SupportTicket({
    required String id,
    required String title,
    required String description,
    @SupportTicketStatusConverter() required SupportTicketStatus status,
    required SocieatyUser user,
    @DateTimeConverter() required DateTime createdAt,
  }) = _SupportTicket;

  factory SupportTicket.fromJson(Map<String, dynamic> json) => _$SupportTicketFromJson(json);
}
