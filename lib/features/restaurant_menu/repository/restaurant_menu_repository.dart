import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/api_client.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/utils/execute_request.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/restaurant_menu/repository/response/create_restaurant_menu_response.dart';
import 'package:socieaty/features/restaurant_menu/repository/response/delete_restaurant_menu_response.dart';
import 'package:socieaty/features/restaurant_menu/repository/response/get_all_menu_categories_response.dart';
import 'package:socieaty/features/restaurant_menu/repository/response/get_all_restaurant_menu_response.dart';
import 'package:socieaty/features/restaurant_menu/repository/response/get_restaurant_menu_response.dart';
import 'package:socieaty/features/restaurant_menu/repository/response/update_restaurant_menu_response.dart';
import 'package:socieaty/features/restaurant_menu/repository/response/update_restaurant_menu_stock_availablity.dart';
import 'package:socieaty/features/restaurant_menu/restaurant/viewstate/create_restaurant_menu_form_state.dart';
import 'package:socieaty/features/restaurant_menu/restaurant/viewstate/update_restaurant_menu_form_state.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';

part 'restaurant_menu_repository.g.dart';

@riverpod
RestaurantMenuRepository restaurantMenuRepository(Ref ref) {
  final AuthLocalRepository authLocalRepository = ref.watch(authLocalRepositoryProvider);
  final token = authLocalRepository.getToken();
  final restaurant = authLocalRepository.getUserData()!;
  return RestaurantMenuRepository(
    dio: ref.watch(apiClientProvider(url: AppConstants.socieatyBackendUrl, token: token)),
    restaurant: restaurant,
  );
}

class RestaurantMenuRepository {
  final Dio dio;
  final SocieatyUser restaurant;
  RestaurantMenuRepository({required this.dio, required this.restaurant});

  Future<ApiResult<CreateRestaurantMenuResponse>> createRestaurantMenu(
    CreateRestaurantMenuFormState data,
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

    return executeRequest<CreateRestaurantMenuResponse>(
      requestFunction: () => dio.post('restaurant/menu', data: formData),
      successParser: (data) => CreateRestaurantMenuResponse.fromJson(data),
    );
  }

  Future<ApiResult<UpdateRestaurantMenuResponse>> updateRestaurantMenu(
    String menuId,
    UpdateRestaurantMenuFormState data,
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

    return executeRequest<UpdateRestaurantMenuResponse>(
      requestFunction: () => dio.put('restaurant/menu/$menuId', data: formData),
      successParser: (data) => UpdateRestaurantMenuResponse.fromJson(data),
    );
  }

  Future<ApiResult<UpdateRestaurantMenuStockAvailabilityResponse>> updateRestaurantMenuStock(
    String menuId,
    bool isAvailable,
  ) {
    return executeRequest<UpdateRestaurantMenuStockAvailabilityResponse>(
      requestFunction: () =>
          dio.put('restaurant/menu/$menuId/stock', data: {'isAvailable': isAvailable}),
      successParser: (data) => UpdateRestaurantMenuStockAvailabilityResponse.fromJson(data),
    );
  }

  Future<ApiResult<DeleteRestaurantMenuResponse>> deleteRestaurantMenu(String menuId) {
    return executeRequest<DeleteRestaurantMenuResponse>(
      requestFunction: () => dio.delete('restaurant/menu/$menuId'),
      successParser: (data) => DeleteRestaurantMenuResponse.fromJson(data),
    );
  }

  Future<ApiResult<GetAllRestaurantMenuResponse>> getAllRestaurantMenu() {
    return executeRequest<GetAllRestaurantMenuResponse>(

      requestFunction: () => dio.get('restaurant/menu/${restaurant.restaurantData?.id}'),
      successParser: (data) => GetAllRestaurantMenuResponse.fromJson(data),
    );
  }

  Future<ApiResult<GetRestaurantMenuResponse>> getRestaurantMenu(String menuId) {
    return executeRequest<GetRestaurantMenuResponse>(
      requestFunction: () => dio.get('restaurant/menu/$menuId'),
      successParser: (data) => GetRestaurantMenuResponse.fromJson(data),
    );
  }

  Future<ApiResult<GetAllMenuCategoriesResponse>> getAllMenuCategories() {
    return executeRequest<GetAllMenuCategoriesResponse>(
      requestFunction: () => dio.get('restaurant/menu/categories'),
      successParser: (data) => GetAllMenuCategoriesResponse.fromJson(data),
    );
  }
}
