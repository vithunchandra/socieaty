import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/topup/model/topup.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';

part 'topup_notification_response.freezed.dart';
part 'topup_notification_response.g.dart';

@freezed
class TopupNotificationResponse with _$TopupNotificationResponse {
  const factory TopupNotificationResponse({
    required Topup topup,
    required SocieatyUser customer,
  }) = _TopupNotificationResponse;

  factory TopupNotificationResponse.fromJson(Map<String, dynamic> json) => _$TopupNotificationResponseFromJson(json);
}