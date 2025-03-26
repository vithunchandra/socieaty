import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/reservation/model/reservation.dart';
import 'package:socieaty/shared/view_state.dart';

part 'create_reservation_view_state.freezed.dart';

@freezed
class CreateReservationViewState with _$CreateReservationViewState {
  const factory CreateReservationViewState({
    required ViewState<Reservation> createdReservation,
  }) = _CreateReservationViewState;
}
