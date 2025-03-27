import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/enums/sort_order_enum.dart';
import 'package:socieaty/core/network/api_client.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/utils/execute_request.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/reservation/customer/viewstate/create_reservation_form_state.dart';
import 'package:socieaty/features/reservation/enum/reservation_sort_by_enum.dart';
import 'package:socieaty/features/reservation/enum/reservation_status_enum.dart';
import 'package:socieaty/features/reservation/repository/responses/create_reservation_response.dart';
import 'package:socieaty/features/reservation/repository/responses/get_reservation_response.dart';
import 'package:socieaty/features/reservation/repository/responses/get_restaurant_reservations_response.dart';
import 'package:socieaty/features/reservation/repository/responses/track_reservation_response.dart';
import 'package:socieaty/features/reservation/repository/responses/update_reservation_response.dart';

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

  Future<ApiResult<CreateReservationResponse>> createReservation(
      CreateReservationFormState formState) {
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

  Future<ApiResult<UpdateReservationResponse>> updateReservation(
      String reservationId, ReservationStatus newStatus) {
    return executeRequest<UpdateReservationResponse>(
      requestFunction: () =>
          _dio.put('reservation/$reservationId', data: {'status': newStatus.name}),
      successParser: (data) => UpdateReservationResponse.fromJson(data),
    );
  }

  Future<ApiResult<GetRestaurantReservationsResponse>> getRestaurantReservations(
    List<ReservationStatus> status,
  ) {
    return executeRequest<GetRestaurantReservationsResponse>(
      requestFunction: () => _dio.get('reservation/restaurant', queryParameters: {
        'status[]': List.generate(status.length, (index) => status[index].name),
      }),
      successParser: (data) => GetRestaurantReservationsResponse.fromJson(data),
    );
  }

  // Using GetRestaurantReservationsResponse temporarily until proper response class is generated
  Future<ApiResult<GetRestaurantReservationsResponse>> getCustomerReservations(
    List<ReservationStatus> status, {
    ReservationSortBy? sortBy,
    SortOrder? sortOrder,
  }) {
    final queryParams = <String, dynamic>{
      'status[]': List.generate(status.length, (index) => status[index].name),
    };

    if (sortBy != null) {
      queryParams['sortBy'] = sortBy.name;
    }

    if (sortOrder != null) {
      queryParams['sortOrder'] = sortOrder.name;
    }

    return executeRequest<GetRestaurantReservationsResponse>(
      requestFunction: () => _dio.get('reservation/customer', queryParameters: queryParams),
      successParser: (data) => GetRestaurantReservationsResponse.fromJson(data),
    );
  }

  Future<ApiResult<TrackReservationResponse>> trackReservation(String reservationId) {
    return executeRequest<TrackReservationResponse>(
      requestFunction: () => _dio.get('reservation/$reservationId/track'),
      successParser: (data) => TrackReservationResponse.fromJson(data),
    );
  }
}
