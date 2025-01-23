import 'package:freezed_annotation/freezed_annotation.dart';

part 'live_room.freezed.dart';
part 'live_room.g.dart';

@freezed
class LiveRoom with _$LiveRoom {
  const factory LiveRoom({
    required String roomName,
    required LiveRoomMetadata metadata,
    required DateTime createdAt,
  }) = _LiveRoom;

  factory LiveRoom.fromJson(Map<String, dynamic> json) => _$LiveRoomFromJson(json);
}

@freezed
class LiveRoomMetadata with _$LiveRoomMetadata {
  const factory LiveRoomMetadata({
    required String roomTitle,
    required String ownerId,
  }) = _LiveRoomMetadata;

  factory LiveRoomMetadata.fromJson(Map<String, dynamic> json) => _$LiveRoomMetadataFromJson(json);
}
