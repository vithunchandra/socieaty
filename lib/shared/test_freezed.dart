import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/authentication/model/signup_customer_response.dart';

part 'test_freezed.freezed.dart';

@freezed
class TestState with _$TestState {
  factory TestState({
    required bool isLoading,
    required bool isSuccess,
    required bool isError,
    required SignupCustomerResponse? data,
    required String message,
  }) = _TestState;
}
