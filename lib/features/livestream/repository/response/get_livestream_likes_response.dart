import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_livestream_likes_response.freezed.dart';
part 'get_livestream_likes_response.g.dart';

@freezed
class GetLivestreamLikesResponse with _$GetLivestreamLikesResponse {
  const factory GetLivestreamLikesResponse({
    required int likes,
  }) = _GetLivestreamLikesResponse;

  factory GetLivestreamLikesResponse.fromJson(Map<String, dynamic> json) => _$GetLivestreamLikesResponseFromJson(json);
}
