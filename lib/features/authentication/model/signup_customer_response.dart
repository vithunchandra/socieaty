import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/customer/model/customer.dart';

part 'signup_customer_response.freezed.dart';
part 'signup_customer_response.g.dart';

@freezed
class SignupCustomerResponse with _$SignupCustomerResponse {
  const factory SignupCustomerResponse({
    required String token,
    required Customer customer,
  }) = _SignupCustomerResponse;

  factory SignupCustomerResponse.fromJson(Map<String, dynamic> json) => _$SignupCustomerResponseFromJson(json);
}
