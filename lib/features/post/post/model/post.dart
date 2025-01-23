import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/post/post_hashtag/model/post_hashtag.dart';
import 'package:socieaty/features/post/post_media/model/post_media.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';

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
    required List<PostHashtag> hashtags,
    required int comments,
    required List<PostMedia> medias,
    required List<SocieatyUser> likes,
  }) = _Post;

  factory Post.fromJson(Map<String, Object?> json) => _$PostFromJson(json);
}
