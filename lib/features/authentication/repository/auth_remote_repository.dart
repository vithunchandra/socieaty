import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/enums/user_role.enum.dart';
import 'package:socieaty/core/network/api_client.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/core/utils/execute_request.dart';
import 'package:socieaty/features/authentication/model/signin_response.dart';
import 'package:socieaty/features/authentication/model/signup_customer_response.dart';
import 'package:socieaty/features/authentication/model/signup_restaurant_response.dart';
import 'package:socieaty/features/authentication/viewstate/signin_form_state.dart';
import 'package:socieaty/features/authentication/viewstate/signup_customer_form_state.dart';
import 'package:socieaty/features/authentication/viewstate/signup_restaurant_form_state.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';

part 'auth_remote_repository.g.dart';

@riverpod
AuthRemoteRepository authRemoteRepository(Ref ref) {
  return AuthRemoteRepository(
    dio: ref.watch(apiClientProvider(url: AppConstants.socieatyBackendUrl)),
  );
}

class AuthRemoteRepository {
  final Dio dio;

  AuthRemoteRepository({required this.dio});

  Future<ApiResult<SignupRestaurantResponse>> signupRestaurant(
    SignupRestaurantFormState data,
    File profilePicture,
    File restaurantBanner,
  ) async {
    String profilePictureExtension = profilePicture.path.split('.').last;
    String restaurantBannerExtension = restaurantBanner.path.split('.').last;
    FormData formData = FormData.fromMap({
      ...data.toJson(),
      'themes[]': List.generate(data.themes.length, (index) => data.themes[index]),
      'role': "Restaurant",
      'profilePicture': await MultipartFile.fromFile(profilePicture.path, filename: "${data.email}.$profilePictureExtension"),
      'restaurantBanner': await MultipartFile.fromFile(restaurantBanner.path, filename: "${data.email}.$restaurantBannerExtension"),
    });
    return executeRequest<SignupRestaurantResponse>(
      requestFunction: () => dio.post("auth/signup/restaurant", data: formData),
      successParser: (data) => SignupRestaurantResponse.fromJson(data),
    );
  }

  Future<ApiResult<SignupCustomerResponse>> signupCustomer(SignupCustomerFormState data) async {
    final payload = {...data.toJson(), 'role': UserRole.customer.name.toCapitalized()};

    return executeRequest<SignupCustomerResponse>(
      requestFunction: () => dio.post("auth/signup/customer", data: payload),
      successParser: (data) => SignupCustomerResponse.fromJson(data),
    );
  }

  Future<ApiResult<SigninResponse>> signinCustomer(SigninFormState data) {
    return executeRequest<SigninResponse>(
      requestFunction: () => dio.post('auth/signin', data: data.toJson()),
      successParser: (data) => SigninResponse.fromJson(data),
    );
  }

  Future<ApiResult<SocieatyUser>> getSessionData(String token) {
    return executeRequest<SocieatyUser>(
      requestFunction: () => dio.get(
        'auth/session/data',
        options: Options(
          headers: {'Authorization': "Bearer $token"},
        ),
      ),
      successParser: (data) => SocieatyUser.fromJson(data),
    );
  }

  Future<ApiResult<SocieatyUser>> getUserData(String id) {
    return executeRequest<SocieatyUser>(
      requestFunction: () => dio.get(
        'auth/user/$id',
      ),
      successParser: (data) => SocieatyUser.fromJson(data),
    );
  }
}
