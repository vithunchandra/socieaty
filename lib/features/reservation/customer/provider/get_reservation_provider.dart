import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/reservation/model/reservation.dart';
import 'package:socieaty/features/reservation/repository/reservation_repository.dart';
import 'package:socieaty/features/reservation/repository/responses/get_reservation_response.dart';

part 'get_reservation_provider.g.dart';

@riverpod
Future<Reservation> getReservation(Ref ref, String reservationId) async {
  final reservationRepository = ref.watch(reservationRepositoryProvider);
  final result = await reservationRepository.getReservation(reservationId);
  switch(result){
    case Success<GetReservationResponse>(data: final data):
      return data.reservation;
    case Error(error: final error):
      throw Exception(error.message);
  }
}
