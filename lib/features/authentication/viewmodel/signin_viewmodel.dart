import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/authentication/provider/session_provider.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/authentication/repository/auth_remote_repository.dart';
import 'package:socieaty/features/authentication/viewstate/signin_form_state.dart';
import 'package:socieaty/features/authentication/viewstate/signin_view_state.dart';

import '../../../shared/view_state.dart';

part 'signin_viewmodel.g.dart';

@riverpod
class SigninViewmodel extends _$SigninViewmodel {
  late AuthRemoteRepository _authRemoteRepository;
  late AuthLocalRepository _authLocalRepository;

  @override
  SigninViewState build() {
    _authRemoteRepository = ref.watch(authRemoteRepositoryProvider);
    _authLocalRepository = ref.watch(authLocalRepositoryProvider);
    return SigninViewState(
      signinState: IdleState(),
    );
  }

  Future<void> signin(SigninFormState data) async {
    state = state.copyWith(signinState: LoadingState());
    final response = await _authRemoteRepository.signinCustomer(data);
    switch (response) {
      case Success(data: final result):
        await _authLocalRepository.setToken(result.token);
        await _authLocalRepository.setUserData(result.user);
        state = state.copyWith(signinState: SuccessState(data: result.user));
      case Error(message: final message):
        state = state.copyWith(signinState: ErrorState(message: message));
    }
  }
}
