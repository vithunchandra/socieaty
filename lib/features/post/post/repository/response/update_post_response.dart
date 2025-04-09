import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/post/post/model/post.dart';

part 'update_post_response.freezed.dart';
part 'update_post_response.g.dart';

@freezed
class UpdatePostResponse with _$UpdatePostResponse {
  const factory UpdatePostResponse({
    required Post post,
  }) = _UpdatePostResponse;

  factory UpdatePostResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdatePostResponseFromJson(json);
}