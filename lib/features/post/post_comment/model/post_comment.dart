import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_comment.freezed.dart';
part 'post_comment.g.dart';

@freezed
class PostComment with _$PostComment {
  factory PostComment({
    required String postId,
    required String userName,
    required String text,
    required int likes,
  }) = _PostComment;

  factory PostComment.fromJson(Map<String, Object?> json) => _$PostCommentFromJson(json);
}
