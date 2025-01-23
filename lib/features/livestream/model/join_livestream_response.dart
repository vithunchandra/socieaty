import 'package:freezed_annotation/freezed_annotation.dart';

part 'join_livestream_response.freezed.dart';
part 'join_livestream_response.g.dart';

@freezed
class JoinLivestreamResponse with _$JoinLivestreamResponse {
  const factory JoinLivestreamResponse({
    required String accessToken,
  }) = _JoinLivestreamResponse;

  factory JoinLivestreamResponse.fromJson(Map<String, dynamic> json) => _$JoinLivestreamResponseFromJson(json);
}
