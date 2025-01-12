import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/api_client.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/home/customer/model/get_all_post_response.dart';

part 'home_repository.g.dart';

@riverpod
HomeRepository homeRepository(Ref ref) {
  final token = ref.watch(authLocalRepositoryProvider).getToken();
  return HomeRepository(
    ref.watch(apiClientProvider(url: AppConstants.socieatyBackendUrl, token: token)),
  );
}

class HomeRepository {
  late final Dio _dio;

  HomeRepository(Dio dio) {
    _dio = dio;
  }

  Future<ApiResult<GetAllPostResponse>> getAllPost() async {
    try {
      final response = await _dio.get("post/");
      return Success(data: GetAllPostResponse.fromJson(response.data));
    } on DioException catch (error) {
      return Error(message: error.extractMesage());
    } on Exception catch (error) {
      return Error(message: error.toString());
    }
  }
}
