import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/reservation/model/reservation.dart';
import 'package:socieaty/shared/view_state.dart';

part 'restaurant_reservation_view_state.freezed.dart';

@freezed
class RestaurantReservationViewState with _$RestaurantReservationViewState {
  const factory RestaurantReservationViewState({
    required String reservationId,
    required ViewState<Reservation> updatedReservation,
  }) = _RestaurantReservationViewState;
}
