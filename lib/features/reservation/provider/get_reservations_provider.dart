import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/reservation/repository/request/get_reservations_query.dart';
import 'package:socieaty/features/reservation/repository/reservation_repository.dart';
import 'package:socieaty/features/reservation/repository/responses/get_reservations_response.dart';

part 'get_reservations_provider.g.dart';

@riverpod
Future<GetReservationsResponse> getReservations(Ref ref, GetReservationsQuery query) async {
  final reservationRepository = ref.watch(reservationRepositoryProvider);
  final result = await reservationRepository.getReservations(query);
  switch (result) {
    case Success(data: final data):
      return data;
    case Error(error: final error):
      throw Exception(error.message);
  }
}
