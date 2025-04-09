import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_media.freezed.dart';
part 'post_media.g.dart';

@freezed
class PostMedia with _$PostMedia {
  factory PostMedia({
    required String id,
    required String url,
    required String type,
    required String postId,
    required String extension,
    @Default(null) String? videoThumbnailUrl,
  }) = _PostMedia;

  factory PostMedia.fromJson(Map<String, Object?> json) => _$PostMediaFromJson(json);
}
