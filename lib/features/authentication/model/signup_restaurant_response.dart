import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';

part 'signup_restaurant_response.freezed.dart';
part 'signup_restaurant_response.g.dart';

@freezed
class SignupRestaurantResponse with _$SignupRestaurantResponse {
  const factory SignupRestaurantResponse({
    required String token,
    required SocieatyUser user,
  }) = _SignupRestaurantResponse;

  factory SignupRestaurantResponse.fromJson(Map<String, dynamic> json) => _$SignupRestaurantResponseFromJson(json);
}
