import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/customer/model/socieaty_customer.dart';
import 'package:socieaty/shared/view_state.dart';

part 'update_customer_profile_view_state.freezed.dart';

@freezed
class UpdateCustomerProfileViewState with _$UpdateCustomerProfileViewState {
  const factory UpdateCustomerProfileViewState({
    required ViewState<SocieatyCustomer> updateCustomerState,
  }) = _UpdateCustomerProfileViewState;
}
