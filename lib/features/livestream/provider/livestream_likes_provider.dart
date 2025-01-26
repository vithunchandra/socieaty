import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/livestream/repository/livestream_repository.dart';

part 'livestream_likes_provider.g.dart';

@riverpod
Future<int> getLivestreamLikes(Ref ref, String roomName) async {
  final result = await ref.watch(livestreamRepositoryProvider).getLivestreamLikes(roomName);
  switch (result) {
    case Success(data: final data):
      return data.likes;
    case Error(message: final message):
      throw Exception(message);
  }
}
