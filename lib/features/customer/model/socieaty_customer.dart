import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/core/enums/user_role.enum.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/customer/model/customer_data.dart';

part 'socieaty_customer.freezed.dart';
part 'socieaty_customer.g.dart';

@freezed
class SocieatyCustomer with _$SocieatyCustomer {
  const factory SocieatyCustomer({
    required String id,
    required String name,
    required String email,
    required String phoneNumber,
    @Default(null) String? profilePictureUrl,
    @UserRoleConverter() required UserRole role,
    required CustomerData customerData,
  }) = _SocieatyCustomer;

  factory SocieatyCustomer.fromJson(Map<String, dynamic> json) => _$SocieatyCustomerFromJson(json);
}
