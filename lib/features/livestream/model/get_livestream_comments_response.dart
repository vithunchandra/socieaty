import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/livestream/model/livestream_comment.dart';

part 'get_livestream_comments_response.freezed.dart';
part 'get_livestream_comments_response.g.dart';

@freezed
class GetLivestreamCommentsResponse with _$GetLivestreamCommentsResponse{
  const factory GetLivestreamCommentsResponse({
    required List<LivestreamComment> comments,
  }) = _GetLivestreamCommentsResponse;

  factory GetLivestreamCommentsResponse.fromJson(Map<String, dynamic> json) => _$GetLivestreamCommentsResponseFromJson(json);
}