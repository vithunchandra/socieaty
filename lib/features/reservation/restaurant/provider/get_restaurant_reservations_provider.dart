import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/reservation/enum/reservation_status_enum.dart';
import 'package:socieaty/features/reservation/model/reservation.dart';
import 'package:socieaty/features/reservation/repository/reservation_repository.dart';

part 'get_restaurant_reservations_provider.g.dart';

@riverpod
Future<List<Reservation>> getRestaurantReservations(Ref ref, List<ReservationStatus> status) async {
  final repository = ref.watch(reservationRepositoryProvider);
  final result = await repository.getRestaurantReservations(status);

  switch (result) {
    case Success(data: var data):
      return data.reservations;
    case Error(error: var error):
      throw error;
  }
}
