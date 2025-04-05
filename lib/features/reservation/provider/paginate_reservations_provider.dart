import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/reservation/repository/request/paginate_reservations_query.dart';
import 'package:socieaty/features/reservation/repository/reservation_repository.dart';
import 'package:socieaty/features/reservation/repository/responses/paginate_reservations_response.dart';

part 'paginate_reservations_provider.g.dart';

@riverpod
Future<PaginateReservationsResponse> paginateReservations(Ref ref, PaginateReservationsQuery query) async {
  final reservationRepository = ref.watch(reservationRepositoryProvider);
  final result = await reservationRepository.paginateReservations(query);
  switch (result) {
    case Success(data: final data):
      return data;
    case Error(error: final error):
      throw Exception(error.message);
  }
}
