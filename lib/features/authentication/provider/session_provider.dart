import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/authentication/repository/auth_remote_repository.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';
import 'package:socieaty/shared/models/network_error.dart';

part 'session_provider.g.dart';

@riverpod
Future<ApiResult<SocieatyUser>> getSessionData(Ref ref) async {
  final token = ref.watch(authLocalRepositoryProvider).getToken();
  if (token == null) {
    return Error(error: NetworkError(message: "Session not found"));
  }
  final result = await ref.watch(authRemoteRepositoryProvider).getSessionData(token);

  switch (result) {
    case Success(data: final user):
      return Success(data: user);
    case Error(error: final error):
      return Error(error: error);
  }
}
