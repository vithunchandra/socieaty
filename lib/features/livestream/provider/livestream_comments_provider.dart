import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/livestream/model/livestream_comment.dart';
import 'package:socieaty/features/livestream/repository/livestream_repository.dart';

part 'livestream_comments_provider.g.dart';

@riverpod
Future<List<LivestreamComment>> getLivestreamComments(Ref ref, String roomName) async {
  final result = await ref.watch(livestreamRepositoryProvider).getLivestreamComments(roomName);
  switch (result) {
    case Success(data: final data):
      return data.comments;
    case Error(message: final message):
      throw Exception(message);
  }
}
