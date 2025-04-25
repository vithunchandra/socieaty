import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/api_client.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/utils/execute_request.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/restaurant/repository/request/get_nearest_restaurant_request_query.dart';
import 'package:socieaty/features/restaurant/repository/response/create_reservation_config_response.dart';
import 'package:socieaty/features/restaurant/repository/response/get_all_restaurant_themes_response.dart';
import 'package:socieaty/features/restaurant/repository/response/get_nearest_restaurant_response.dart';
import 'package:socieaty/features/restaurant/repository/response/get_reservation_config_response.dart';
import 'package:socieaty/features/restaurant/repository/response/get_reservation_facilities_suggestion_response.dart';
import 'package:socieaty/features/restaurant/repository/response/paginate_restaurant_response.dart';
import 'package:socieaty/features/restaurant/repository/response/update_reservation_config_response.dart';
import 'package:socieaty/features/restaurant/viewstate/create_reservation_config_form_state.dart';
import 'package:socieaty/features/restaurant/viewstate/paginate_restaurant_query_state.dart';
import 'package:socieaty/features/restaurant/viewstate/update_reservation_config_form_state.dart';

part 'restaurant_respository.g.dart';

@riverpod
RestaurantRespository restaurantRespository(Ref ref) {
  return RestaurantRespository(
    dio: ref.watch(
      apiClientProvider(
        url: AppConstants.socieatyBackendUrl,
        token: ref.watch(authLocalRepositoryProvider).getToken(),
      ),
    ),
  );
}

class RestaurantRespository {
  late final Dio _dio;

  RestaurantRespository({required Dio dio}) {
    _dio = dio;
  }

  Future<ApiResult<CreateReservationConfigResponse>> createReservationConfig(
      CreateReservationConfigFormState formState) {
    return executeRequest<CreateReservationConfigResponse>(
      requestFunction: () => _dio.post('restaurant/reservation-config', data: formState.toJson()),
      successParser: (data) => CreateReservationConfigResponse.fromJson(data),
    );
  }

  Future<ApiResult<UpdateReservationConfigResponse>> updateReservationConfig(
      UpdateReservationConfigFormState formState) {
    return executeRequest<UpdateReservationConfigResponse>(
      requestFunction: () => _dio.put('restaurant/reservation-config', data: formState.toJson()),
      successParser: (data) => UpdateReservationConfigResponse.fromJson(data),
    );
  }

  Future<ApiResult<GetReservationConfigResponse>> getReservationConfig(String restaurantId) {
    return executeRequest<GetReservationConfigResponse>(
      requestFunction: () => _dio.get('restaurant/reservation-config/$restaurantId'),
      successParser: (data) => GetReservationConfigResponse.fromJson(data),
    );
  }

  Future<ApiResult<PaginateRestaurantResponse>> paginateRestaurants(
      PaginateRestaurantQueryState query) {
    final queryData = {
      'name': query.name,
      'minRating': query.minRating,
      'priceConditionIds[]': query.priceRanges,
      'categoryIds[]': query.foodCategories,
      'themeIds[]': query.themes,
      'paginationQuery': query.paginationQuery.toJson(),
    };
    return executeRequest<PaginateRestaurantResponse>(
      requestFunction: () => _dio.get('restaurant', queryParameters: queryData),
      successParser: (data) => PaginateRestaurantResponse.fromJson(data),
    );
  }

  Future<ApiResult<GetNearestRestaurantResponse>> getNearestRestaurant(
      GetNearestRestaurantRequestQuery query) {
    return executeRequest<GetNearestRestaurantResponse>(
      requestFunction: () => _dio.get('restaurant/nearest', queryParameters: query.toJson()),
      successParser: (data) => GetNearestRestaurantResponse.fromJson(data),
    );
  }

  Future<ApiResult<GetAllRestaurantThemesResponse>> getAllRestaurantThemes() {
    return executeRequest<GetAllRestaurantThemesResponse>(
      requestFunction: () => _dio.get('restaurant/themes'),
      successParser: (data) => GetAllRestaurantThemesResponse.fromJson(data),
    );
  }

  Future<ApiResult<GetReservationFacilitiesSuggestionResponse>> getReservationFacilitiesSuggestion(
      String name) {
    return executeRequest<GetReservationFacilitiesSuggestionResponse>(
      requestFunction: () => _dio.get('restaurant/facilities', queryParameters: {'name': name}),
      successParser: (data) => GetReservationFacilitiesSuggestionResponse.fromJson(data),
    );
  }
}
