import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/core/enums/user_role.enum.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/customer/model/customer_data.dart';
import 'package:socieaty/features/restaurant/model/restaurant_data.dart';

part 'socieaty_user.freezed.dart';
part 'socieaty_user.g.dart';

@freezed
class SocieatyUser with _$SocieatyUser {
  const factory SocieatyUser({
    required String id,
    required String name,
    required String email,
    required String phoneNumber,
    @Default(null) String? profilePictureUrl,
    @UserRoleConverter() required UserRole role,
    @Default(null) RestaurantData? restaurantData,
    @Default(null) CustomerData? customerData,
  }) = _SocieatyUser;

  factory SocieatyUser.fromJson(Map<String, dynamic> json) => _$SocieatyUserFromJson(json);
}
