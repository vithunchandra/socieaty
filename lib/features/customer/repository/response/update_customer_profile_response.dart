import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';

part 'update_customer_profile_response.freezed.dart';
part 'update_customer_profile_response.g.dart';

@freezed
class UpdateCustomerProfileResponse with _$UpdateCustomerProfileResponse {
  const factory UpdateCustomerProfileResponse({
    required SocieatyUser updatedUser,
  }) = _UpdateCustomerProfileResponse;

  factory UpdateCustomerProfileResponse.fromJson(Map<String, dynamic> json) => _$UpdateCustomerProfileResponseFromJson(json);
}
