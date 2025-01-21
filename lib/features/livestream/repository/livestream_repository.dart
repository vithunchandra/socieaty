import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/api_client.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/utils/execute_request.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/livestream/model/start_livestream_response.dart';
import 'package:socieaty/features/livestream/viewstate/setup_livestream_form_state.dart';

part 'livestream_repository.g.dart';

@riverpod
LivestreamRepository livestreamRepository(Ref ref) {
  final token = ref.watch(authLocalRepositoryProvider).getToken();
  return LivestreamRepository(
    ref.watch(apiClientProvider(url: AppConstants.socieatyBackendUrl, token: token)),
  );
}

class LivestreamRepository {
  late final Dio _dio;

  LivestreamRepository(Dio dio) {
    _dio = dio;
  }

  Future<ApiResult<StartLivestreamResponse>> startLivestream(SetupLivestreamFormState data) async {
    return executeRequest(
      requestFunction: () async => await _dio.post('livestream/start', data: data.toJson()),
      successParser: (data) => StartLivestreamResponse.fromJson(data),
    );
  }
}
