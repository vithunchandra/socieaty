import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/post/post/model/post.dart';

part 'get_post_response.freezed.dart';
part 'get_post_response.g.dart';

@freezed
class GetPostResponse with _$GetPostResponse {
  const factory GetPostResponse({
    required Post post,
  }) = _GetPostResponse;

  factory GetPostResponse.fromJson(Map<String, dynamic> json) => _$GetPostResponseFromJson(json);
}
