import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/livestream/model/live_room.dart';

part 'get_livestream_rooms_response.freezed.dart';
part 'get_livestream_rooms_response.g.dart';

@freezed
class GetLivestreamRoomsResponse with _$GetLivestreamRoomsResponse {
  const factory GetLivestreamRoomsResponse({
    required List<LiveRoom> rooms,
  }) = _GetLivestreamRoomsResponse;

  factory GetLivestreamRoomsResponse.fromJson(Map<String, dynamic> json) => _$GetLivestreamRoomsResponseFromJson(json);
}
