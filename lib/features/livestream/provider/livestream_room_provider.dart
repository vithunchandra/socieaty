import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/livestream/model/get_livestream_rooms_response.dart';
import 'package:socieaty/features/livestream/repository/livestream_repository.dart';

part 'livestream_room_provider.g.dart';

@riverpod
Future<GetLivestreamRoomsResponse> getLivestreamRooms(Ref ref) async {
  final result = await ref.watch(livestreamRepositoryProvider).getLivestreamRooms();
  switch (result) {
    case Success(data: final data):
      return data;
    case Error(message: final message):
      throw Exception(message);
  }
}
