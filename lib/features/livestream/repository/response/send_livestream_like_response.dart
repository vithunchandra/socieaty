import 'package:freezed_annotation/freezed_annotation.dart';

part 'send_livestream_like_response.freezed.dart';
part 'send_livestream_like_response.g.dart';

@freezed
class SendLivestreamLikeResponse with _$SendLivestreamLikeResponse {
  factory SendLivestreamLikeResponse({
    required bool isLiked,
    required int likes,
  }) = _SendLivestreamLikeResponse;

  factory SendLivestreamLikeResponse.fromJson(Map<String, dynamic> json) => _$SendLivestreamLikeResponseFromJson(json);
}
