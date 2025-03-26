import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/reservation/model/reservation.dart';
import 'package:socieaty/shared/view_state.dart';

part 'update_reservation_status_view_state.freezed.dart';

@freezed
class UpdateReservationStatusViewState with _$UpdateReservationStatusViewState {
  const factory UpdateReservationStatusViewState({
    required String reservationId,
    required ViewState<Reservation> updatedReservation,
  }) = _UpdateReservationStatusViewState;
}
