import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/customer/repository/customer_profile_remote_repository.dart';
import 'package:socieaty/features/customer/viewstate/customer_profile_viewstate.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';
import 'package:socieaty/shared/view_state.dart';

part 'customer_profile_viewmodel.g.dart';

@riverpod
Future<SocieatyUser> getCustomerProfile(Ref ref) async {
  final token = ref.watch(authLocalRepositoryProvider).getToken();
  if (token == null) {
    throw "Session not found";
  }
  final result = await ref.watch(customerProfileRemoteRepositoryProvider).getProfile();
  switch (result) {
    case Success<SocieatyUser>(data: final user):
      return user;
    case Error(message: final message):
      throw message;
  }
}
