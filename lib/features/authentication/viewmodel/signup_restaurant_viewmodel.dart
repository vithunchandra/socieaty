import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/authentication/model/signup_restaurant_response.dart';
import 'package:socieaty/features/authentication/repository/auth_remote_repository.dart';
import 'package:socieaty/features/authentication/viewstate/signup_restaurant_form_state.dart';
import 'package:socieaty/features/authentication/viewstate/signup_restaurant_view_state.dart';
import 'package:socieaty/shared/view_state.dart';

part 'signup_restaurant_viewmodel.g.dart';

@riverpod
class SignupRestaurantViewModel extends _$SignupRestaurantViewModel {
  late AuthRemoteRepository _authRemoteRepository;
  @override
  SignupRestaurantViewState build() {
    _authRemoteRepository = ref.watch(authRemoteRepositoryProvider);
    return SignupRestaurantViewState(signupRestaurantState: IdleState());
  }

  Future<void> signupRestaurant(SignupRestaurantFormState data, File selectedImage) async {
    state = state.copyWith(signupRestaurantState: IdleState());
    final response = await _authRemoteRepository.signupRestaurant(data, selectedImage);
    switch (response) {
      case Success<SignupRestaurantResponse>(data: final result):
        state = state.copyWith(signupRestaurantState: SuccessState(data: result.user));
      case Error(message: final message):
        state = state.copyWith(signupRestaurantState: ErrorState(message: message));
    }
  }
}
