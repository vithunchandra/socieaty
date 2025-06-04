import 'package:freezed_annotation/freezed_annotation.dart';

part 'delete_post_comment_response.freezed.dart';
part 'delete_post_comment_response.g.dart';

@freezed
class DeletePostCommentResponse with _$DeletePostCommentResponse {
  const factory DeletePostCommentResponse({
    required String message,
  }) = _DeletePostCommentResponse;

  factory DeletePostCommentResponse.fromJson(Map<String, dynamic> json) =>
      _$DeletePostCommentResponseFromJson(json);
}
