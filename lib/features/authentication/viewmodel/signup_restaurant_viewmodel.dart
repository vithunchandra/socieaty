import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/authentication/model/signup_restaurant_form_state.dart';
import 'package:socieaty/features/authentication/model/signup_restaurant_response.dart';
import 'package:socieaty/features/authentication/repository/auth_remote_repository.dart';

part 'signup_restaurant_viewmodel.g.dart';

@riverpod
class SignupRestaurantViewModel extends _$SignupRestaurantViewModel {
  late final AuthRemoteRepository _authRemoteRepository;

  @override
  AsyncValue<SignupRestaurantResponse>? build() {
    _authRemoteRepository = ref.watch(authRemoteRepositoryProvider);
    return null;
  }

  Future<void> signupRestaurant(SignupRestaurantFormState data, File selectedImage) async {
    state = AsyncValue.loading();

    final response = await _authRemoteRepository.signupRestaurant(data, selectedImage);
    switch (response) {
      case Success<SignupRestaurantResponse>(data: final result):
        state = AsyncValue.data(result);
      case Error(message: final message):
        state = AsyncValue.error(message, StackTrace.current);
    }
  }
}
