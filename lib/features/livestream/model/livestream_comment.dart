import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';

part 'livestream_comment.freezed.dart';
part 'livestream_comment.g.dart';

@freezed 
class LivestreamComment with _$LivestreamComment {
  factory LivestreamComment({
    required String id,
    required String roomName,
    required SocieatyUser user,
    required String text,
  }) = _LivestreamComment;

  factory LivestreamComment.fromJson(Map<String, dynamic> json) => _$LivestreamCommentFromJson(json);
}