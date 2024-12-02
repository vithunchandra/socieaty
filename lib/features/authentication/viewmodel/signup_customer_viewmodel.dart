import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/features/authentication/model/signup_customer_form_state.dart';
import 'package:socieaty/features/authentication/model/signup_customer_response.dart';

import '../../../core/network/api_result.dart';
import '../repository/auth_remote_repository.dart';

part 'signup_customer_viewmodel.g.dart';

@riverpod
class SignupCustomerViewmodel extends _$SignupCustomerViewmodel {
  late final AuthRemoteRepository _authRemoteRepository;

  @override
  AsyncValue<SignupCustomerResponse>? build() {
    _authRemoteRepository = ref.watch(authRemoteRepositoryProvider);
    return null;
  }

  Future<void> signupRestaurant(SignupCustomerFormState data) async {
    state = AsyncValue.loading();

    final response = await _authRemoteRepository.signupCustomer(data);
    switch (response) {
      case Success<SignupCustomerResponse>(data: final result):
        state = AsyncValue.data(result);
      case Error(message: final message):
        state = AsyncValue.error(message, StackTrace.current);
    }
  }
}
