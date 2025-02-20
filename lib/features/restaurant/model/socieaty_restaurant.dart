import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/core/enums/user_role.enum.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/restaurant/model/restaurant_data.dart';

part 'socieaty_restaurant.freezed.dart';
part 'socieaty_restaurant.g.dart';

@freezed
class SocieatyRestaurant with _$SocieatyRestaurant {
  const factory SocieatyRestaurant({
    required String id,
    required String name,
    required String email,
    required String phoneNumber,
    @Default(null) String? profilePictureUrl,
    @UserRoleConverter() required UserRole role,
    required RestaurantData restaurantData,
  }) = _Restaurant;

  factory SocieatyRestaurant.fromJson(Map<String, dynamic> json) =>
      _$SocieatyRestaurantFromJson(json);
}
