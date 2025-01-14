import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/authentication/model/signup_restaurant_response.dart';
import 'package:socieaty/features/authentication/provider/session_provider.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/authentication/repository/auth_remote_repository.dart';
import 'package:socieaty/features/authentication/viewstate/signup_restaurant_form_state.dart';
import 'package:socieaty/features/authentication/viewstate/signup_restaurant_view_state.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';
import 'package:socieaty/shared/view_state.dart';

part 'signup_restaurant_viewmodel.g.dart';

@riverpod
class SignupRestaurantViewModel extends _$SignupRestaurantViewModel {
  late AuthRemoteRepository _authRemoteRepository;
  late AuthLocalRepository _authLocalRepository;

  @override
  SignupRestaurantViewState build() {
    _authRemoteRepository = ref.watch(authRemoteRepositoryProvider);
    _authLocalRepository = ref.watch(authLocalRepositoryProvider);
    return SignupRestaurantViewState(signupRestaurantState: IdleState());
  }

  Future<void> signupRestaurant(SignupRestaurantFormState data, File selectedImage) async {
    state = state.copyWith(signupRestaurantState: IdleState());
    final response = await _authRemoteRepository.signupRestaurant(data, selectedImage);
    switch (response) {
      case Success<SignupRestaurantResponse>(data: final result):
        await _authLocalRepository.setToken(result.token);
        ref.watch(getSessionDataProvider).whenData((data) async {
          if(data is Success<SocieatyUser>){
            await _authLocalRepository.setUserData(data.data);
          }else{
            throw Exception("Session not found");
          }
        });
        state = state.copyWith(signupRestaurantState: SuccessState(data: result.user));
      case Error(message: final message):
        state = state.copyWith(signupRestaurantState: ErrorState(message: message));
    }
  }
}
