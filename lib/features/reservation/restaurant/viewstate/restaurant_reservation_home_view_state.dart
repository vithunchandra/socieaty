import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';
import 'package:socieaty/shared/view_state.dart';

part 'restaurant_reservation_home_view_state.freezed.dart';

@freezed
class RestaurantReservationHomeViewState with _$RestaurantReservationHomeViewState {
  const factory RestaurantReservationHomeViewState({
    required ViewState<SocieatyRestaurant> toggleReservationState,
  }) = _RestaurantReservationHomeViewState;
}
