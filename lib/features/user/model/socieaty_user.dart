import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/customer/model/customer.dart';
import 'package:socieaty/features/restaurant/model/restaurant.dart';

part 'socieaty_user.freezed.dart';
part 'socieaty_user.g.dart';

@freezed
class SocieatyUser with _$SocieatyUser {
  const factory SocieatyUser({
    required String email,
    required String phoneNumber,
    required String role,
    @Default(null) Restaurant? restaurantData,
    @Default(null) Customer? customerData,
  }) = _SocieatyUser;

  factory SocieatyUser.fromJson(Map<String, dynamic> json) => _$SocieatyUserFromJson(json);
}
