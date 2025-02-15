import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_hashtag.g.dart';
part 'post_hashtag.freezed.dart';

@freezed
class PostHashtag with _$PostHashtag {
  const factory PostHashtag({
    required String id,
    required String tag,
  }) = _PostHashtag;

  factory PostHashtag.fromJson(Map<String, Object?> json) => _$PostHashtagFromJson(json);
}
