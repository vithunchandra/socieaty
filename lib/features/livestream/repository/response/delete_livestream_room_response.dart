import 'package:freezed_annotation/freezed_annotation.dart';

part 'delete_livestream_room_response.freezed.dart';
part 'delete_livestream_room_response.g.dart';

@freezed
class DeleteLivestreamRoomResponse with _$DeleteLivestreamRoomResponse {
  const factory DeleteLivestreamRoomResponse({
    required bool isDeleted,
  }) = _DeleteLivestreamRoomResponse;

  factory DeleteLivestreamRoomResponse.fromJson(Map<String, dynamic> json) => _$DeleteLivestreamRoomResponseFromJson(json);
}
