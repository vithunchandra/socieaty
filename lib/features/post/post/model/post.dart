import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socieaty/core/utils/LatLngConverter.dart';
import 'package:socieaty/features/post/post/model/post_like.dart';
import 'package:socieaty/features/post/post_comment/model/post_comment.dart';
import 'package:socieaty/features/post/post_media/model/post_media.dart';

part 'post.freezed.dart';
part 'post.g.dart';

@freezed
class Post with _$Post {
  factory Post({
    required String id,
    required String authorId,
    required String authorName,
    required String title,
    required String caption,
    @Default(null) @LatLngConverter() LatLng? location,
    required List<PostComment> comments,
    required List<PostMedia> medias,
    required List<PostLike> likes,
  }) = _Post;

  factory Post.fromJson(Map<String, Object?> json) => _$PostFromJson(json);
}
