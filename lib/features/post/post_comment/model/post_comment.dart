import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';

part 'post_comment.freezed.dart';
part 'post_comment.g.dart';

@freezed
class PostComment with _$PostComment {
  factory PostComment({
    required String id,
    required String postId,
    required String userName,
    required String text,
    required List<SocieatyUser> likes,
  }) = _PostComment;

  factory PostComment.fromJson(Map<String, Object?> json) => _$PostCommentFromJson(json);
}
