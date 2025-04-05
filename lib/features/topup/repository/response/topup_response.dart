import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/topup/model/topup.dart';

part 'topup_response.freezed.dart';
part 'topup_response.g.dart';

@freezed
class TopupResponse with _$TopupResponse {
  const factory TopupResponse({
    required Topup topup,

  }) = _TopupResponse;

  factory TopupResponse.fromJson(Map<String, dynamic> json) => _$TopupResponseFromJson(json);
}