import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';

import '../../../core/enums/user_role.enum.dart';
import '../../../core/utils/user_role_converter.dart';

part 'customer.freezed.dart';
part 'customer.g.dart';

@freezed
class Customer with _$Customer {
  const factory Customer(
      {required String id,
      required String name,
      @Default(null) String? photoProfileUrl,
      @Default(null) String? bio,
      required int wallet,
      required String email,
      required String phoneNumber,
      @UserRoleConverter() required UserRole role}) = _Customer;

  factory Customer.fromJson(Map<String, dynamic> json) => _$CustomerFromJson(json);
}
