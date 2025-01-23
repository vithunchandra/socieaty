import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socieaty/core/utils/converter.dart';

part 'signup_restaurant_form_state.freezed.dart';
part 'signup_restaurant_form_state.g.dart';

@freezed
class SignupRestaurantFormState with _$SignupRestaurantFormState {
  const factory SignupRestaurantFormState({
    @Default(null) String? name,
    @Default(null) String? email,
    @Default(null) String? password,
    @Default(null) String? confirmPassword,
    @Default(null) String? phoneNumber,
    @Default(null) String? restaurantName,
    @LatLngConverter() @Default(null) LatLng? address,
  }) = _SignupRestaurantFormState;

  factory SignupRestaurantFormState.fromJson(Map<String, Object?> json) => _$SignupRestaurantFormStateFromJson(json);
}
