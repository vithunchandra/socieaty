
import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/enums/user_role.enum.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/customer/repository/customer_profile_remote_repository.dart';
import 'package:socieaty/features/customer/repository/response/update_customer_profile_response.dart';
import 'package:socieaty/features/customer/viewstate/update_customer_profile_form_state.dart';
import 'package:socieaty/features/customer/viewstate/update_customer_profile_view_state.dart';
import 'package:socieaty/shared/view_state.dart';

part 'update_customer_profile_view_model.g.dart';

@riverpod
class UpdateCustomerProfileViewModel extends _$UpdateCustomerProfileViewModel {
  late CustomerProfileRemoteRepository customerProfileRemoteRepository;

  @override
  UpdateCustomerProfileViewState build() {
    customerProfileRemoteRepository = ref.watch(customerProfileRemoteRepositoryProvider);
    return UpdateCustomerProfileViewState(
      updateCustomerState: IdleState(),
    );
  }
  
  Future<void> updateProfile(UpdateCustomerProfileFormState data, File? profilePicture) async {
    state = state.copyWith(updateCustomerState: LoadingState());
    final result = await customerProfileRemoteRepository.updateProfile(data, profilePicture);
    switch (result) {
      case Success<UpdateCustomerProfileResponse>(data: final data):
        if (data.updatedUser.role == UserRole.customer && data.updatedUser.customerData != null) {
          state = state.copyWith(updateCustomerState: SuccessState(data: UserConverter.userToCustomer(data.updatedUser)));
        } else {
          state = state.copyWith(updateCustomerState: ErrorState(message: 'User is not a customer'));
        }
      case Error(error: final error):
        state = state.copyWith(updateCustomerState: ErrorState(message: error.message));
    }
  }
}
