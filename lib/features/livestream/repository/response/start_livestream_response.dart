import 'package:freezed_annotation/freezed_annotation.dart';

part 'start_livestream_response.freezed.dart';
part 'start_livestream_response.g.dart';

@freezed
class StartLivestreamResponse with _$StartLivestreamResponse {
  const factory StartLivestreamResponse({
    required String accessToken,
  }) = _StartLivestreamResponse;

  factory StartLivestreamResponse.fromJson(Map<String, dynamic> json) => _$StartLivestreamResponseFromJson(json);
}
