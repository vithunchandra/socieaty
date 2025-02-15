import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/livestream/repository/livestream_repository.dart';

part 'join_livestream_provider.g.dart';

@Riverpod(keepAlive: true)
Future<String> joinLivestream(Ref ref, String roomTitle) async {
  final result = await ref.watch(livestreamRepositoryProvider).joinLivestream(roomTitle);
  switch (result) {
    case Success(:final data):
      return data.accessToken;
    case Error(error: final error):
      throw Exception(error.message);
  }
}
