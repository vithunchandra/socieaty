import 'package:freezed_annotation/freezed_annotation.dart';

part 'livestream_likes.freezed.dart';
part 'livestream_likes.g.dart';

@freezed
class LivestreamLikes with _$LivestreamLikes {
  factory LivestreamLikes({
    required String roomName,
    required int likes,
  }) = _LivestreamLikes;

  factory LivestreamLikes.fromJson(Map<String, dynamic> json) =>
      _$LivestreamLikesFromJson(json);
}
