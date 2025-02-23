import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/post/post/model/post.dart';

part 'create_post_response.freezed.dart';
part 'create_post_response.g.dart';

@freezed
class CreatePostResponse with _$CreatePostResponse {
  const factory CreatePostResponse({required Post post}) = _CreatePostResponse;

  factory CreatePostResponse.fromJson(Map<String, dynamic> json) => _$CreatePostResponseFromJson(json);
}
