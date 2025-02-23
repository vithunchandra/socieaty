import 'package:freezed_annotation/freezed_annotation.dart';

part 'like_post_comment_response.freezed.dart';
part 'like_post_comment_response.g.dart';

@freezed
class LikePostCommentResponse with _$LikePostCommentResponse {
  factory LikePostCommentResponse({
    required bool isLiked,
    required int likes,
  }) = _LikePostCommentResponse;

  factory LikePostCommentResponse.fromJson(Map<String, dynamic> json) => _$LikePostCommentResponseFromJson(json);
}
