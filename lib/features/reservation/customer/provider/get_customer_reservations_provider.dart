import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/reservation/customer/viewstate/get_reservations_history_query_state.dart';
import 'package:socieaty/features/reservation/model/reservation.dart';
import 'package:socieaty/features/reservation/repository/reservation_repository.dart';

final getCustomerReservationsProvider =
    FutureProvider.family<List<Reservation>, GetReservationsHistoryQueryState>(
  (ref, queryState) async {
    final repository = ref.watch(reservationRepositoryProvider);
    final result = await repository.getCustomerReservations(
      queryState.reservationStatus,
      sortBy: queryState.sortBy,
      sortOrder: queryState.sortOrder,
    );
    
    switch (result) {
      case Success(data: final data):
        debugPrint('data: $data');
        return data.reservations;
      case Error(error: final error):
        throw Exception(error.message);
    }
  },
);
