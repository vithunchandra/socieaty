import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_is_liked_response.freezed.dart';
part 'get_is_liked_response.g.dart';

@freezed
class GetIsLikedResponse with _$GetIsLikedResponse {
  factory GetIsLikedResponse({required bool isLiked}) = _GetIsLikedResponse;

  factory GetIsLikedResponse.fromJson(Map<String, dynamic> json) => _$GetIsLikedResponseFromJson(json);
}
