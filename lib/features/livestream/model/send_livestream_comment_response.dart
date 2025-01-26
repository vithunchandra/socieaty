import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/livestream/model/livestream_comment.dart';

part 'send_livestream_comment_response.freezed.dart';
part 'send_livestream_comment_response.g.dart';

@freezed
class SendLivestreamCommentResponse with _$SendLivestreamCommentResponse {
  const factory SendLivestreamCommentResponse({
    required LivestreamComment comment,
  }) = _SendLivestreamCommentResponse;

  factory SendLivestreamCommentResponse.fromJson(Map<String, dynamic> json) => _$SendLivestreamCommentResponseFromJson(json);
}
