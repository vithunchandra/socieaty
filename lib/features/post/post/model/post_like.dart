import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_like.freezed.dart';
part 'post_like.g.dart';

@freezed
class PostLike with _$PostLike {
  factory PostLike({
    required String postId,
    required String userId,
    required String userName,
  }) = _PostLike;

  factory PostLike.fromJson(Map<String, dynamic> json) => _$PostLikeFromJson(json);
}
