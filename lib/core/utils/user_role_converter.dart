import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/core/enums/user_role.enum.dart';
import 'package:socieaty/core/utils/custom_extension.dart';

class UserRoleConverter implements JsonConverter<UserRole, String> {
  const UserRoleConverter();

  @override
  UserRole fromJson(String json) {
    if (json.toLowerCase() == UserRole.restaurant.name.toLowerCase()) {
      return UserRole.restaurant;
    } else if (json.toLowerCase() == UserRole.customer.name.toLowerCase()) {
      return UserRole.customer;
    } else {
      return UserRole.admin;
    }
  }

  @override
  String toJson(UserRole object) {
    return object.name.toCapitalized();
  }
}
