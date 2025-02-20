import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_customer_profile_form_state.freezed.dart';
part 'update_customer_profile_form_state.g.dart';

@freezed
class UpdateCustomerProfileFormState with _$UpdateCustomerProfileFormState {
  factory UpdateCustomerProfileFormState({
    required String profileUserId,
    @Default('') String name,
    @Default('') String phoneNumber,
    @Default('') String bio,
  }) = _UpdateCustomerProfileFormState;

  factory UpdateCustomerProfileFormState.fromJson(Map<String, dynamic> json) => _$UpdateCustomerProfileFormStateFromJson(json);
}
