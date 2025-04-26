import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/api_client.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/core/utils/execute_request.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';
import 'package:socieaty/features/user/repository/request/paginate_users_request_query.dart';
import 'package:socieaty/features/user/repository/response/paginate_users_response.dart';

part 'user_repository.g.dart';

@riverpod
UserRepository userRepository(Ref ref) {
  final AuthLocalRepository authLocalRepository = ref.watch(authLocalRepositoryProvider);
  final token = authLocalRepository.getToken();
  return UserRepository(
    dio: ref.watch(
      apiClientProvider(url: AppConstants.socieatyBackendUrl, token: token),
    ),
  );
}

class UserRepository {
  final Dio _dio;

  UserRepository({required Dio dio}) : _dio = dio;

  Future<ApiResult<SocieatyUser>> getUserData(String id) {
    return executeRequest<SocieatyUser>(
      requestFunction: () => _dio.get(
        'users/$id',
      ),
      successParser: (data) => SocieatyUser.fromJson(data),
    );
  }

  Future<ApiResult<PaginateUsersResponse>> paginateUsers(PaginateUsersRequestQuery query) {
    final queryData = {
      'searchQuery': query.searchQuery,
      'role': query.role?.name.toCapitalized(),
      'paginationQuery': query.paginationQuery.toJson(),
    };
    return executeRequest<PaginateUsersResponse>(
      requestFunction: () => _dio.get(
        'users',
        queryParameters: queryData,
      ),
      successParser: (data) => PaginateUsersResponse.fromJson(data),
    );
  }

  Future<ApiResult<SocieatyUser>> deleteUser(String id) {
    debugPrint('deleteUser: $id');
    return executeRequest<SocieatyUser>(
      requestFunction: () => _dio.delete(
        'users/$id',
      ),
      successParser: (data) => SocieatyUser.fromJson(data),
    );
  }

  Future<ApiResult<SocieatyUser>> undeleteUser(String id) {
    return executeRequest<SocieatyUser>(
      requestFunction: () => _dio.put(
        'users/$id/undelete',
      ),
      successParser: (data) => SocieatyUser.fromJson(data),
    );
  }
}
