import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_media.freezed.dart';
part 'post_media.g.dart';

@freezed
class PostMedia with _$PostMedia {
  factory PostMedia({
    required String url,
    required String type,
    required String postId,
  }) = _PostMedia;

  factory PostMedia.fromJson(Map<String, Object?> json) => _$PostMediaFromJson(json);
}
