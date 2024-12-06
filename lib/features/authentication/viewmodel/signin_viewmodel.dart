import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/cupertino.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/env.dart';
import 'package:socieaty/features/authentication/repository/auth_remote_repository.dart';
import 'package:socieaty/features/authentication/viewstate/signin_form_state.dart';
import 'package:socieaty/features/authentication/viewstate/signin_view_state.dart';

import '../../../core/network/api_result.dart';
import '../../../shared/view_state.dart';

part 'signin_viewmodel.g.dart';

@riverpod
class SigninViewmodel extends _$SigninViewmodel {
  late final AuthRemoteRepository _authRemoteRepository;

  @override
  SigninViewState build() {
    _authRemoteRepository = ref.watch(authRemoteRepositoryProvider);
    return SigninViewState(
      signinState: IdleState(),
    );
  }

  Future<void> signin(SigninFormState data) async {
    state = state.copyWith(signinState: LoadingState());
    final response = await _authRemoteRepository.signinCustomer(data);
    switch (response) {
      case Success(data: final result):
        try{
          final jwt = JWT.verify(result.token, SecretKey(Env.jwtSocieatySecretKey));
          state = state.copyWith(signinState: SuccessState(data: "Berhasil login"));
        } on JWTException catch(error){
          state = state.copyWith(signinState: ErrorState(message: error.message));
        }
      case Error(message: final message):
        state = state.copyWith(signinState: ErrorState(message: message));
    }
  }
}
