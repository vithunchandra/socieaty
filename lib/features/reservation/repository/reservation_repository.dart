import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/api_client.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/utils/execute_request.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/reservation/customer/viewstate/create_reservation_form_state.dart';
import 'package:socieaty/features/reservation/repository/responses/create_reservation_response.dart';
import 'package:socieaty/features/reservation/repository/responses/get_reservation_response.dart';

part 'reservation_repository.g.dart';

@riverpod
ReservationRepository reservationRepository(Ref ref) {
  final AuthLocalRepository authLocalRepository = ref.watch(authLocalRepositoryProvider);
  final token = authLocalRepository.getToken();
  return ReservationRepository(
    dio: ref.watch(apiClientProvider(url: AppConstants.socieatyBackendUrl, token: token)),
  );
}

class ReservationRepository {
  final Dio _dio;

  ReservationRepository({required Dio dio}) : _dio = dio;
  
  Future<ApiResult<CreateReservationResponse>> createReservation(CreateReservationFormState formState) {
    return executeRequest<CreateReservationResponse>(
      requestFunction: () => _dio.post('reservation', data: formState.toJson()),
      successParser: (data) => CreateReservationResponse.fromJson(data),
    );
  }

  Future<ApiResult<GetReservationResponse>> getReservation(String reservationId) {
    return executeRequest<GetReservationResponse>(
      requestFunction: () => _dio.get('reservation/$reservationId'),
      successParser: (data) => GetReservationResponse.fromJson(data),
    );
  }
}
