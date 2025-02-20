import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/post/post/model/post.dart';

part 'like_post_response.freezed.dart';
part 'like_post_response.g.dart';

@freezed
class LikePostResponse with _$LikePostResponse {
  factory LikePostResponse({
    required Post updatedPost,
    required bool isLiked,
    required int likes,
  }) = _LikePostResponse;

  factory LikePostResponse.fromJson(Map<String, dynamic> json) => _$LikePostResponseFromJson(json);
}
