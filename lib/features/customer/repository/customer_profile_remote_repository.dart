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
import 'package:socieaty/features/customer/repository/response/update_customer_profile_response.dart';
import 'package:socieaty/features/customer/viewstate/update_customer_profile_form_state.dart';

part 'customer_profile_remote_repository.g.dart';

@riverpod
CustomerProfileRemoteRepository customerProfileRemoteRepository(Ref ref) {
  final token = ref.watch(authLocalRepositoryProvider).getToken();
  return CustomerProfileRemoteRepository(
    dio: ref.watch(apiClientProvider(url: AppConstants.socieatyBackendUrl, token: token)),
  );
}

class CustomerProfileRemoteRepository {
  late final Dio _dio;

  CustomerProfileRemoteRepository({required Dio dio}) {
    _dio = dio;
  }

  Future<ApiResult<UpdateCustomerProfileResponse>> updateProfile(
      UpdateCustomerProfileFormState data, File? profilePicture) {
    debugPrint('profilePicture: ${profilePicture != null}');
    final formData = FormData.fromMap({
      ...data.toJson(),
      'profilePicture':
          profilePicture != null ? MultipartFile.fromFileSync(profilePicture.path) : null,
    });
    return executeRequest<UpdateCustomerProfileResponse>(
      requestFunction: () => _dio.put('customer/profile', data: formData),
      successParser: (data) => UpdateCustomerProfileResponse.fromJson(data),
    );
  }
}
