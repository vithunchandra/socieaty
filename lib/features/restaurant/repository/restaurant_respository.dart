import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/api_client.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/utils/execute_request.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/restaurant/repository/response/get_all_restaurant_themes_response.dart';
import 'package:socieaty/features/restaurant/repository/response/paginate_restaurant_response.dart';
import 'package:socieaty/features/restaurant/viewstate/paginate_restaurant_query_state.dart';

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

  Future<ApiResult<PaginateRestaurantResponse>> paginateRestaurants(
      PaginateRestaurantQueryState query) {
    final queryData = {
      'name': query.name,
      'minRating': query.minRating,
      'priceConditionIds[]': query.priceRanges,
      'categoryIds[]': query.foodCategories,
      'themeIds[]': query.themes,
      'offset': query.offset,
      'limit': query.limit,
    };
    debugPrint(queryData.toString());
    return executeRequest<PaginateRestaurantResponse>(
      requestFunction: () => _dio.get('restaurant', queryParameters: queryData),
      successParser: (data) => PaginateRestaurantResponse.fromJson(data),
    );
  }

  Future<ApiResult<GetAllRestaurantThemesResponse>> getAllRestaurantThemes() {
    return executeRequest<GetAllRestaurantThemesResponse>(
      requestFunction: () => _dio.get('restaurant/themes'),
      successParser: (data) => GetAllRestaurantThemesResponse.fromJson(data),
    );
  }
}
