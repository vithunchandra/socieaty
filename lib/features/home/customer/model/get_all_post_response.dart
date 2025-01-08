import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/post/post/model/post.dart';

part 'get_all_post_response.freezed.dart';
part 'get_all_post_response.g.dart';

@freezed
class GetAllPostResponse with _$GetAllPostResponse {
  factory GetAllPostResponse({required List<Post> posts}) = _GetAllPostResponse;

  factory GetAllPostResponse.fromJson(Map<String, dynamic> json) => _$GetAllPostResponseFromJson(json);
}
