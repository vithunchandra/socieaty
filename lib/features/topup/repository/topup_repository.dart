import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/api_client.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/utils/execute_request.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/topup/repository/response/topup_response.dart';
import 'package:socieaty/features/topup/repository/response/track_topup_response.dart';

part 'topup_repository.g.dart';

@riverpod
TopupRepository topupRepository(Ref ref) {
  final AuthLocalRepository authLocalRepository = ref.watch(authLocalRepositoryProvider);
  final token = authLocalRepository.getToken();
  return TopupRepository(
    dio: ref.watch(apiClientProvider(url: AppConstants.socieatyBackendUrl, token: token)),
  );
}

class TopupRepository {
  final Dio _dio;

  TopupRepository({required Dio dio}) : _dio = dio;

  Future<ApiResult<TopupResponse>> createTopup(double grossAmount) async {
    return executeRequest<TopupResponse>(
      requestFunction: () => _dio.post('topup', data: {'grossAmount': grossAmount}),
      successParser: (data) => TopupResponse.fromJson(data),
    );
  }

  Future<ApiResult<TrackTopupResponse>> trackTopup(String id) async {
    return executeRequest<TrackTopupResponse>(
      requestFunction: () => _dio.get('topup/$id/track'),
      successParser: (data) => TrackTopupResponse.fromJson(data),
    );
  }
}
