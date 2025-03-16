import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/api_client.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/utils/execute_request.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/food_menu/repository/response/create_food_menu_response.dart';
import 'package:socieaty/features/food_menu/repository/response/delete_food_menu_response.dart';
import 'package:socieaty/features/food_menu/repository/response/get_all_menu_categories_response.dart';
import 'package:socieaty/features/food_menu/repository/response/get_all_food_menu_response.dart';
import 'package:socieaty/features/food_menu/repository/response/get_food_menu_response.dart';
import 'package:socieaty/features/food_menu/repository/response/get_menu_categories_by_popularity_response.dart';
import 'package:socieaty/features/food_menu/repository/response/paginate_food_menu_response.dart';
import 'package:socieaty/features/food_menu/repository/response/update_food_menu_response.dart';
import 'package:socieaty/features/food_menu/repository/response/update_food_menu_stock_availablity.dart';
import 'package:socieaty/features/food_menu/restaurant/viewstate/create_food_menu_form_state.dart';
import 'package:socieaty/features/food_menu/restaurant/viewstate/paginate_menu_form_state.dart';
import 'package:socieaty/features/food_menu/restaurant/viewstate/update_food_menu_form_state.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';
import 'package:socieaty/shared/widgets/menu_filter_widget.dart';

part 'food_menu_repository.g.dart';

@riverpod
FoodMenuRepository foodMenuRepository(Ref ref) {
  final AuthLocalRepository authLocalRepository = ref.watch(authLocalRepositoryProvider);
  final token = authLocalRepository.getToken();
  final restaurant = authLocalRepository.getUserData()!;
  return FoodMenuRepository(
    dio: ref.watch(apiClientProvider(url: AppConstants.socieatyBackendUrl, token: token)),
    restaurant: restaurant,
  );
}

class FoodMenuRepository {
  final Dio dio;
  final SocieatyUser restaurant;
  FoodMenuRepository({required this.dio, required this.restaurant});

  Future<ApiResult<CreateFoodMenuResponse>> createFoodMenu(
    CreateFoodMenuFormState data,
    File menuPicture,
  ) async {
    String menuPictureExtension = menuPicture.path.split('.').last;
    FormData formData = FormData.fromMap(
      {
        ...data.toJson(),
        'categories[]': List.generate(data.categories.length, (index) => data.categories[index]),
        'menuPicture': await MultipartFile.fromFile(menuPicture.path,
            filename: "${restaurant.name}_${data.name}.$menuPictureExtension"),
      },
    );

    return executeRequest<CreateFoodMenuResponse>(
      requestFunction: () => dio.post('menu', data: formData),
      successParser: (data) => CreateFoodMenuResponse.fromJson(data),
    );
  }

  Future<ApiResult<UpdateFoodMenuResponse>> updateFoodMenu(
    String menuId,
    UpdateFoodMenuFormState data,
    File? menuPicture,
  ) async {
    FormData formData = FormData.fromMap({
      ...data.toJson(),
    });

    if (menuPicture != null) {
      String menuPictureExtension = menuPicture.path.split('.').last;
      formData.files.add(MapEntry(
          'menuPicture',
          await MultipartFile.fromFile(menuPicture.path,
              filename: "${restaurant.name}_${data.name}.$menuPictureExtension")));
    }

    return executeRequest<UpdateFoodMenuResponse>(
      requestFunction: () => dio.put('menu/$menuId', data: formData),
      successParser: (data) => UpdateFoodMenuResponse.fromJson(data),
    );
  }

  Future<ApiResult<UpdateFoodMenuStockAvailabilityResponse>> updateFoodMenuStock(
    String menuId,
    bool isAvailable,
  ) {
    return executeRequest<UpdateFoodMenuStockAvailabilityResponse>(
      requestFunction: () => dio.put('menu/$menuId/stock', data: {'isAvailable': isAvailable}),
      successParser: (data) => UpdateFoodMenuStockAvailabilityResponse.fromJson(data),
    );
  }

  Future<ApiResult<DeleteFoodMenuResponse>> deleteFoodMenu(String menuId) {
    return executeRequest<DeleteFoodMenuResponse>(
      requestFunction: () => dio.delete('menu/$menuId'),
      successParser: (data) => DeleteFoodMenuResponse.fromJson(data),
    );
  }

  Future<ApiResult<PaginateFoodMenuResponse>> getPaginatedFoodMenu(PaginateMenuFormState? query) {
    final queryData = {
      'searchQuery': query?.searchQuery,
      'minRating': query?.minRating ?? 0,
      'priceConditionIds[]': query?.priceRanges,
      'categoryIds[]': query?.categories,
      'offset': query?.offset,
      'limit': query?.limit,
    };
    debugPrint('queryData: $queryData');
    return executeRequest<PaginateFoodMenuResponse>(
      requestFunction: () => dio.get('menu', queryParameters: queryData),
      successParser: (data) => PaginateFoodMenuResponse.fromJson(data),
    );
  }

  Future<ApiResult<GetAllFoodMenuResponse>> getAllFoodMenu(
      String restaurantId, MenuFilterFormState? query) {
    final queryData = {
      'searchQuery': query?.searchQuery ?? '',
      'minRating': query?.minRating ?? 0,
      'priceConditionIds[]': query?.priceRanges.toList() ?? [],
      'categoryIds[]': query?.categories.toList() ?? [],
    };
    debugPrint('queryData: $queryData');
    return executeRequest<GetAllFoodMenuResponse>(
      requestFunction: () => dio.get(
        'menu/$restaurantId',
        queryParameters: queryData,
      ),
      successParser: (data) => GetAllFoodMenuResponse.fromJson(data),
    );
  }

  Future<ApiResult<GetFoodMenuResponse>> getFoodMenu(String menuId) {
    return executeRequest<GetFoodMenuResponse>(
      requestFunction: () => dio.get('menu/single/$menuId'),
      successParser: (data) => GetFoodMenuResponse.fromJson(data),
    );
  }

  Future<ApiResult<GetAllMenuCategoriesResponse>> getAllMenuCategories() {
    return executeRequest<GetAllMenuCategoriesResponse>(
      requestFunction: () => dio.get('menu/categories'),
      successParser: (data) {
        return GetAllMenuCategoriesResponse.fromJson(data);
      },
    );
  }

  Future<ApiResult<GetMenuCategoriesByPopularityResponse>> getMenuCategoriesByPopularity() {
    return executeRequest<GetMenuCategoriesByPopularityResponse>(
      requestFunction: () => dio.get('menu/categories/popular'),
      successParser: (data) => GetMenuCategoriesByPopularityResponse.fromJson(data),
    );
  }
}
