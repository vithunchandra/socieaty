import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socieaty/core/enums/bank.enum.dart';
import 'package:socieaty/core/enums/sort_order_enum.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/core/enums/user_role.enum.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/features/customer/model/socieaty_customer.dart';
import 'package:socieaty/features/food-order/enum/food_order_status_enum.dart';
import 'package:socieaty/features/food-order/model/food_order_transaction.dart';
import 'package:socieaty/features/reservation/enum/reservation_sort_by_enum.dart';
import 'package:socieaty/features/reservation/enum/reservation_status_enum.dart';
import 'package:socieaty/features/reservation/model/reservation.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';
import 'package:socieaty/features/support-ticket/enum/support_ticket_status_enum.dart';
import 'package:socieaty/features/topup/enum/topup_status_enum.dart';
import 'package:socieaty/features/transaction/model/transaction.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';
import 'package:socieaty/features/restaurant/enum/restaurant_verification_status_enum.dart';

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

class TransactionConverter {
  static Transaction foodOrderToTransaction(FoodOrderTransaction foodOrder) {
    return Transaction(
      transactionId: foodOrder.transactionId,
      status: foodOrder.status,
      serviceType: foodOrder.serviceType,
      grossAmount: foodOrder.grossAmount,
      netAmount: foodOrder.netAmount,
      refundAmount: foodOrder.refundAmount,
      serviceFee: foodOrder.serviceFee,
      note: foodOrder.note,
      restaurant: foodOrder.restaurant,
      customer: foodOrder.customer,
    );
  }

  static Transaction reservationToTransaction(Reservation reservation) {
    return Transaction(
      transactionId: reservation.transactionId,
      status: reservation.status,
      serviceType: TransactionServiceType.reservation,
      grossAmount: reservation.grossAmount,
      netAmount: reservation.netAmount,
      refundAmount: reservation.refundAmount,
      serviceFee: reservation.serviceFee,
      note: reservation.note,
      restaurant: reservation.restaurant,
      customer: reservation.customer,
    );
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

class ReservationStatusConverter implements JsonConverter<ReservationStatus, String> {
  const ReservationStatusConverter();

  @override
  ReservationStatus fromJson(String json) {
    return ReservationStatus.values.firstWhere((element) => element.name == json);
  }

  @override
  String toJson(ReservationStatus object) {
    return object.name;
  }
}

class ListReservationStatusConverter implements JsonConverter<List<ReservationStatus>, List<String>> {
  const ListReservationStatusConverter();

  @override
  List<ReservationStatus> fromJson(List<String> json) {
    return json.map((e) => ReservationStatus.values.firstWhere((element) => element.name == e)).toList();
  }

  @override
  List<String> toJson(List<ReservationStatus> object) {
    return object.map((e) => e.name).toList();
  }
}

class TopupStatusConverter implements JsonConverter<TopupStatusEnum, String> {
  const TopupStatusConverter();

  @override
  TopupStatusEnum fromJson(String json) {
    return TopupStatusEnum.values.firstWhere((element) => element.name == json);
  } 

  @override
  String toJson(TopupStatusEnum object) {
    return object.name;
  }
}

class SupportTicketStatusConverter implements JsonConverter<SupportTicketStatus, String> {
  const SupportTicketStatusConverter();

  @override
  SupportTicketStatus fromJson(String json) {
    return SupportTicketStatus.values.firstWhere((element) => element.name == json);
  }

  @override
  String toJson(SupportTicketStatus object) {
    return object.name;
  }
}

class ReservationSortByConverter implements JsonConverter<ReservationSortBy, String> {
  const ReservationSortByConverter();

  @override
  ReservationSortBy fromJson(String json) {
    return ReservationSortBy.values.firstWhere((element) => element.name == json);
  }

  @override
  String toJson(ReservationSortBy object) {
    return object.name;
  }
}

class SortOrderConverter implements JsonConverter<SortOrder, String> {
  const SortOrderConverter();

  @override
  SortOrder fromJson(String json) {
    return SortOrder.values.firstWhere((element) => element.name == json);
  }

  @override
  String toJson(SortOrder object) {
    return object.name;
  }
}

class RestaurantVerificationStatusConverter implements JsonConverter<RestaurantVerificationStatus, String> {
  const RestaurantVerificationStatusConverter();

  @override
  RestaurantVerificationStatus fromJson(String json) {
    return RestaurantVerificationStatus.values.firstWhere((element) => element.name == json);
  }

  @override
  String toJson(RestaurantVerificationStatus object) {
    return object.name;
  }
}

class SocieatyRestaurantConverter
    implements JsonConverter<SocieatyRestaurant, Map<String, dynamic>> {
  const SocieatyRestaurantConverter();

  @override
  SocieatyRestaurant fromJson(Map<String, dynamic> json) {
    final SocieatyUser user = SocieatyUser.fromJson(json);
    return UserConverter.userToRestaurant(user);
  }

  @override
  Map<String, dynamic> toJson(SocieatyRestaurant object) {
    return object.toJson();
  }
}

class SocieatyCustomerConverter implements JsonConverter<SocieatyCustomer, Map<String, dynamic>> {
  const SocieatyCustomerConverter();

  @override
  SocieatyCustomer fromJson(Map<String, dynamic> json) {
    final SocieatyUser user = SocieatyUser.fromJson(json);
    return UserConverter.userToCustomer(user);
  }

  @override
  Map<String, dynamic> toJson(SocieatyCustomer object) {
    return object.toJson();
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

  static SocieatyUser customerToUser(SocieatyCustomer customer) {
    return SocieatyUser(
      id: customer.id,
      name: customer.name,
      email: customer.email,
      phoneNumber: customer.phoneNumber,
      profilePictureUrl: customer.profilePictureUrl,
      role: UserRole.customer,
      customerData: customer.customerData,
    );
  }

  static SocieatyUser restaurantToUser(SocieatyRestaurant restaurant) {
    return SocieatyUser(
      id: restaurant.id,
      name: restaurant.name,
      email: restaurant.email,
      phoneNumber: restaurant.phoneNumber,
      profilePictureUrl: restaurant.profilePictureUrl,
      role: UserRole.restaurant,
      restaurantData: restaurant.restaurantData,
    );
  }
}

class DateTimeConverter implements JsonConverter<DateTime, String> {
  const DateTimeConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json).toLocal();

  @override
  String toJson(DateTime object) => object.toIso8601String();
}
