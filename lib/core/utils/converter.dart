import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socieaty/core/enums/bank.enum.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/core/enums/user_role.enum.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/features/customer/model/socieaty_customer.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';

class LatLngConverter implements JsonConverter<LatLng, Map<String, dynamic>> {
  const LatLngConverter();

  @override
  LatLng fromJson(Map<String, dynamic> json) {
    return LatLng(
      double.parse(json['latitude'].toString()),
      double.parse(json['longitude'].toString()),
    );
  }

  @override
  Map<String, dynamic> toJson(LatLng object) {
    return {
      'latitude': object.latitude,
      'longitude': object.longitude,
    };
  }
}

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

class BankConverter implements JsonConverter<BankEnum, String> {
  const BankConverter();

  @override
  BankEnum fromJson(String json) {
    if (json.toLowerCase() == BankEnum.bri.name.toLowerCase()) {
      return BankEnum.bri;
    } else if (json.toLowerCase() == BankEnum.bni.name.toLowerCase()) {
      return BankEnum.bni;
    } else if (json.toLowerCase() == BankEnum.bca.name.toLowerCase()) {
      return BankEnum.bca;
    } else {
      return BankEnum.mandiri;
    }
  }

  @override
  String toJson(BankEnum object) {
    return object.name;
  }
}

class TransactionServiceTypeConverter implements JsonConverter<TransactionServiceType, String> {
  const TransactionServiceTypeConverter();

  @override
  TransactionServiceType fromJson(String json) {
    return TransactionServiceType.values.firstWhere((element) => element.value == json);
  }

  @override
  String toJson(TransactionServiceType object) {
    return object.value;
  }
}

class FoodOrderStatusConverter implements JsonConverter<FoodOrderStatus, String> {
  const FoodOrderStatusConverter();

  @override
  FoodOrderStatus fromJson(String json) {
    return FoodOrderStatus.values.firstWhere((element) => element.name == json);
  }

  @override
  String toJson(FoodOrderStatus object) {
    return object.name;
  }
}

class TransactionStatusConverter implements JsonConverter<TransactionStatus, String> {
  const TransactionStatusConverter();

  @override
  TransactionStatus fromJson(String json) {
    return TransactionStatus.values.firstWhere((element) => element.name == json);
  }

  @override
  String toJson(TransactionStatus object) {
    return object.name;
  }
}

class UserConverter {
  static SocieatyCustomer userToCustomer(SocieatyUser user) {
    return SocieatyCustomer(
      id: user.id,
      name: user.name,
      email: user.email,
      phoneNumber: user.phoneNumber,
      profilePictureUrl: user.profilePictureUrl,
      role: user.role,
      customerData: user.customerData!,
    );
  }

  static SocieatyRestaurant userToRestaurant(SocieatyUser user) {
    return SocieatyRestaurant(
      id: user.id,
      name: user.name,
      email: user.email,
      phoneNumber: user.phoneNumber,
      profilePictureUrl: user.profilePictureUrl,
      role: user.role,
      restaurantData: user.restaurantData!,
    );
  }
}
