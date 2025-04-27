import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/livestream/model/live_room.dart';
import 'package:socieaty/features/livestream/repository/livestream_repository.dart';
import 'package:socieaty/features/livestream/repository/request/get_all_livestream_request_query.dart';

part 'livestream_room_provider.g.dart';

@riverpod
Future<List<LiveRoom>> getLivestreamRooms(Ref ref, GetAllLivestreamRequestQuery query) async {
  final result = await ref.watch(livestreamRepositoryProvider).getLivestreamRooms(query);
  switch (result) {
    case Success(data: final data):
      return data.rooms;
    case Error(error: final error):
      throw Exception(error.message);
  }
}
