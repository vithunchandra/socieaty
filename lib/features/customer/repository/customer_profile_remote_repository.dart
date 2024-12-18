import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/api_client.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
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

  Future<ApiResult<SocieatyUser>> getProfile() async {
    try {
      final response = await _dio.get('customer/profile');
      return Success(data: SocieatyUser.fromJson(response.data));
    } on DioException catch (error) {
      return Error(message: error.extractMesage());
    } on Exception catch (error) {
      return Error(message: error.toString());
    }
  }
}
