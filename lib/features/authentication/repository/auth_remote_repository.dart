import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/api_client.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/authentication/model/signup_customer_form_state.dart';
import 'package:socieaty/features/authentication/model/signup_customer_response.dart';
import 'package:socieaty/features/authentication/model/signup_restaurant_form_state.dart';
import 'package:socieaty/features/authentication/model/signup_restaurant_response.dart';

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

  Future<ApiResult<SignupRestaurantResponse>> signupRestaurant(SignupRestaurantFormState data, File image) async {
    try {
      String extension = image.path.split('.').last;
      FormData formData = FormData.fromMap({
        ...data.toJson(),
        'role': "Restaurant",
        'image': await MultipartFile.fromFile(image.path, filename: "${data.restaurantName}.$extension"),
      });
      final response = await Dio().post("http://10.0.2.2:3000/auth/signup/restaurant", data: formData);
      return Success(data: SignupRestaurantResponse.fromJson(response.data));
    } catch (error) {
      return Error(message: error.toString());
    }
  }

  Future<ApiResult<SignupCustomerResponse>> signupCustomer(SignupCustomerFormState data) async {
    try {
      final response = await Dio().post("http://10.0.2.2:3000/auth/signup/customer", data: jsonEncode(data));
      return Success(data: SignupCustomerResponse.fromJson(response.data));
    } catch (error) {
      return Error(message: error.toString());
    }
  }
}
