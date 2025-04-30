import 'package:freezed_annotation/freezed_annotation.dart';

part 'verify_resturant_account_response.freezed.dart';
part 'verify_resturant_account_response.g.dart';

@freezed
class VerifyRestaurantAccountResponse with _$VerifyRestaurantAccountResponse {
  const factory VerifyRestaurantAccountResponse({
    required String message,
  }) = _VerifyRestaurantAccountResponse;

  factory VerifyRestaurantAccountResponse.fromJson(Map<String, dynamic> json) => _$VerifyRestaurantAccountResponseFromJson(json);
}
