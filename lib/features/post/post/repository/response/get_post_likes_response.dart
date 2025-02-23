import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/post/post/model/post_like.dart';

part 'get_post_likes_response.freezed.dart';
part 'get_post_likes_response.g.dart';

@freezed
class GetPostLikesResponse with _$GetPostLikesResponse {
  factory GetPostLikesResponse({required PostLike likes}) = _GetPostLikesResponse;

  factory GetPostLikesResponse.fromJson(Map<String, dynamic> json) => _$GetPostLikesResponseFromJson(json);
}
