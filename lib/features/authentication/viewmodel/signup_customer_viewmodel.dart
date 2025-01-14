import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/features/authentication/model/signup_customer_response.dart';
import 'package:socieaty/features/authentication/provider/session_provider.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/authentication/viewstate/signup_customer_form_state.dart';
import 'package:socieaty/features/authentication/viewstate/signup_customer_view_state.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';
import 'package:socieaty/shared/view_state.dart';

import '../../../core/network/api_result.dart';
import '../repository/auth_remote_repository.dart';

part 'signup_customer_viewmodel.g.dart';

@riverpod
class SignupCustomerViewmodel extends _$SignupCustomerViewmodel {
  late AuthRemoteRepository _authRemoteRepository;
  late AuthLocalRepository _authLocalRepository;

  @override
  SignupCustomerViewState build() {
    _authRemoteRepository = ref.watch(authRemoteRepositoryProvider);
    _authLocalRepository = ref.watch(authLocalRepositoryProvider);
    return SignupCustomerViewState(
      signupState: IdleState(),
    );
  }

  Future<void> signupCustomer(SignupCustomerFormState data) async {
    state = state.copyWith(signupState: LoadingState());
    final response = await _authRemoteRepository.signupCustomer(data);
    switch (response) {
      case Success<SignupCustomerResponse>(data: final result):
        await _authLocalRepository.setToken(result.token);
        ref.watch(getSessionDataProvider).whenData((data) async {
          if(data is Success<SocieatyUser>){
            await _authLocalRepository.setUserData(data.data);
          }else{
            throw Exception("Session not found");
          }
        });
        state = state.copyWith(signupState: SuccessState(data: result.user));
      case Error(message: final message):
        state = state.copyWith(signupState: ErrorState(message: message));
    }
  }
}
