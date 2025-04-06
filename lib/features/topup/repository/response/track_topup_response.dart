import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/topup/model/topup.dart';

part 'track_topup_response.freezed.dart';
part 'track_topup_response.g.dart';

@freezed
class TrackTopupResponse with _$TrackTopupResponse {
  const factory TrackTopupResponse({
    required Topup topup,
  }) = _TrackTopupResponse;

  factory TrackTopupResponse.fromJson(Map<String, dynamic> json) => _$TrackTopupResponseFromJson(json);
}