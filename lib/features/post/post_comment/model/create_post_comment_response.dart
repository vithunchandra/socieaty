import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/post/post_comment/model/post_comment.dart';

part 'create_post_comment_response.freezed.dart';
part 'create_post_comment_response.g.dart';

@freezed
class CreatePostCommentResponse with _$CreatePostCommentResponse {
  const factory CreatePostCommentResponse({required PostComment comment}) = _CreatePostCommentResponse;

  factory CreatePostCommentResponse.fromJson(Map<String, dynamic> json) => _$CreatePostCommentResponseFromJson(json);
}
