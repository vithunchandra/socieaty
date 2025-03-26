import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/reservation/repository/reservation_repository.dart';
import 'package:socieaty/features/reservation/restaurant/viewstate/update_reservation_status_view_state.dart';
import 'package:socieaty/shared/view_state.dart';

part 'update_reservation_status_view_model.g.dart';

@riverpod
class UpdateReservationStatusViewModel extends _$UpdateReservationStatusViewModel {
  late ReservationRepository _reservationRepository;

  @override
  UpdateReservationStatusViewState build(String reservationId) {
    _reservationRepository = ref.read(reservationRepositoryProvider);
    return UpdateReservationStatusViewState(
      reservationId: reservationId,
      updatedReservation: IdleState(),
    );
  }

  Future<void> updateReservationStatus(ReservationStatus newStatus) async {
    state = state.copyWith(updatedReservation: const LoadingState());

    final result = await _reservationRepository.updateReservation(reservationId, newStatus);

    switch (result) {
      case Success(data: var data):
        state = state.copyWith(updatedReservation: SuccessState(data: data.reservation));
      case Error(error: var error):
        state = state.copyWith(updatedReservation: ErrorState(message: error.message));
    }
  }
}
