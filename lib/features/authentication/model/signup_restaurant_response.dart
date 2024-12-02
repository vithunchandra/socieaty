import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/restaurant/model/restaurant.dart';

part 'signup_restaurant_response.freezed.dart';
part 'signup_restaurant_response.g.dart';

@freezed
class SignupRestaurantResponse with _$SignupRestaurantResponse {
  const factory SignupRestaurantResponse({
    required String token,
    required Restaurant restaurant,
  }) = _SignupRestaurantResponse;

  factory SignupRestaurantResponse.fromJson(Map<String, Object?> json) => _$SignupRestaurantResponseFromJson(json);
}
