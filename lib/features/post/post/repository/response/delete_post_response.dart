import 'package:freezed_annotation/freezed_annotation.dart';

part 'delete_post_response.freezed.dart';
part 'delete_post_response.g.dart';

@freezed
class DeletePostResponse with _$DeletePostResponse {
  const factory DeletePostResponse({
    required String message,
  }) = _DeletePostResponse;

  factory DeletePostResponse.fromJson(Map<String, dynamic> json) => _$DeletePostResponseFromJson(json);
}


