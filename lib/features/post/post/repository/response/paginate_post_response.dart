import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/post/post/model/post.dart';
import 'package:socieaty/shared/models/pagination.dart';

part 'paginate_post_response.freezed.dart';
part 'paginate_post_response.g.dart';

@freezed
class PaginatePostResponse with _$PaginatePostResponse {
  const factory PaginatePostResponse({
    required List<Post> posts,
    required Pagination pagination,
  }) = _PaginatePostResponse;

  factory PaginatePostResponse.fromJson(Map<String, dynamic> json) =>
      _$PaginatePostResponseFromJson(json);
}
