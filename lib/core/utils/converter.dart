import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socieaty/core/enums/bank.enum.dart';
import 'package:socieaty/core/enums/user_role.enum.dart';
import 'package:socieaty/core/utils/custom_extension.dart';

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
    } else{
      return BankEnum.mandiri;
    }
  }

  @override
  String toJson(BankEnum object) {
    return object.name;
  }
}
