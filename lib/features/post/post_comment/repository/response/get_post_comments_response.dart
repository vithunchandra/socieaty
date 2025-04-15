import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/post/post_comment/model/post_comment.dart';

part 'get_post_comments_response.freezed.dart';
part 'get_post_comments_response.g.dart';

@freezed
class GetPostCommentsResponse with _$GetPostCommentsResponse {
  factory GetPostCommentsResponse({required List<PostComment> comments}) = _GetPostCommentsResponse;

  factory GetPostCommentsResponse.fromJson(Map<String, dynamic> json) =>
      _$GetPostCommentsResponseFromJson(json);
}
