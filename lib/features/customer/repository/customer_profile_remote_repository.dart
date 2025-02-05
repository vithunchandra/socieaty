import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/api_client.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/utils/execute_request.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';

part 'customer_profile_remote_repository.g.dart';

@riverpod
CustomerProfileRemoteRepository customerProfileRemoteRepository(Ref ref) {
  final token = ref.watch(authLocalRepositoryProvider).getToken();
  return CustomerProfileRemoteRepository(
    dio: ref.watch(apiClientProvider(url: AppConstants.socieatyBackendUrl, token: token)),
  );
}

class CustomerProfileRemoteRepository {
  late final Dio _dio;

  CustomerProfileRemoteRepository({required Dio dio}) {
    _dio = dio;
  }

  Future<ApiResult<SocieatyUser>> getProfile() {
    return executeRequest<SocieatyUser>(
      requestFunction: () => _dio.get('customer/profile'),
      successParser: (data) => SocieatyUser.fromJson(data),
    );
  }
}
