import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/customer/model/socieaty_customer.dart';
import 'package:socieaty/features/menu_item/model/menu_item.dart';
import 'package:socieaty/features/reservation/enum/reservation_status_enum.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';

part 'reservation.freezed.dart';
part 'reservation.g.dart';

@freezed
class Reservation with _$Reservation {
  const factory Reservation({
    required String transactionId,
    @TransactionServiceTypeConverter() required TransactionServiceType serviceType,
    required int grossAmount,
    required int netAmount,
    required int refundAmount,
    required int serviceFee,
    required String note,
    @TransactionStatusConverter() required TransactionStatus status,
    required SocieatyRestaurant restaurant,
    required SocieatyCustomer customer,
    required String reservationId,
    @ReservationStatusConverter() required ReservationStatus reservationStatus,
    @DateTimeConverter() required DateTime reservationTime,
    @DateTimeConverter() required DateTime endTimeEstimation,
    required int peopleSize,
    required List<MenuItem> menuItems,
    @DateTimeConverter() required DateTime createdAt,
    @DateTimeConverter() required DateTime updatedAt,
    @DateTimeConverter() required DateTime? finishedAt,
  }) = _Reservation;

  factory Reservation.fromJson(Map<String, dynamic> json) => _$ReservationFromJson(json);
}
