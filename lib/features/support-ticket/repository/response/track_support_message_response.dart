import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/support-ticket/model/support_ticket_message.dart';

part 'track_support_message_response.freezed.dart';
part 'track_support_message_response.g.dart';

@freezed
class TrackSupportMessageResponse with _$TrackSupportMessageResponse {
  const factory TrackSupportMessageResponse({
    required List<SupportTicketMessage> supportTicketMessages,
  }) = _TrackSupportMessageResponse;

  factory TrackSupportMessageResponse.fromJson(Map<String, dynamic> json) => _$TrackSupportMessageResponseFromJson(json);
}