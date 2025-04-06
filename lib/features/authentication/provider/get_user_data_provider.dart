import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/authentication/repository/auth_remote_repository.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';

part 'get_user_data_provider.g.dart';

@riverpod
Future<SocieatyUser> getUserData(Ref ref, String userId) async {
  final result = await ref.watch(authRemoteRepositoryProvider).getUserData(userId);
  switch (result) {
    case Success<SocieatyUser>(data: final user):
      return user;
    case Error(error: final error):
      throw Exception(error.message);
  }
}
