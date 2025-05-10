import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';

part 'get_current_user_data_provider.g.dart';

@riverpod
SocieatyUser? getCurrentUserData(Ref ref) {
  final repository = ref.read(authLocalRepositoryProvider);
  return repository.getUserData();
}
