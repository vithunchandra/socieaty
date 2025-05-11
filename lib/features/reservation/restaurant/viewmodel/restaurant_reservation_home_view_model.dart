import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/reservation/restaurant/viewstate/restaurant_reservation_home_view_state.dart';
import 'package:socieaty/features/restaurant/repository/request/toggle_reservation_availability_request.dart';
import 'package:socieaty/features/restaurant/repository/response/toggle_reservation_availability_response.dart';
import 'package:socieaty/features/restaurant/repository/restaurant_respository.dart';
import 'package:socieaty/shared/view_state.dart';

part 'restaurant_reservation_home_view_model.g.dart';

@riverpod
class RestaurantReservationHomeViewModel extends _$RestaurantReservationHomeViewModel {
  late RestaurantRespository _restaurantRepository;

  @override
  RestaurantReservationHomeViewState build() {
    _restaurantRepository = ref.watch(restaurantRespositoryProvider);
    return RestaurantReservationHomeViewState(
      toggleReservationState: IdleState(),
    );
  }

  Future<void> toggleReservationAvailability(bool value) async {
    state = state.copyWith(toggleReservationState: LoadingState());
    final result = await _restaurantRepository.toggleReservationAvailability(
      ToggleReservationAvailabilityRequest(value: value),
    );
    switch (result) {
      case Success<ToggleReservationAvailabilityResponse>(data: final data):
        await ref.read(authLocalRepositoryProvider).setUserData(
              UserConverter.restaurantToUser(data.restaurant),
            );
        state = state.copyWith(toggleReservationState: SuccessState(data: data.restaurant));

      case Error():
        state =
            state.copyWith(toggleReservationState: ErrorState(message: result.error.toString()));
    }
  }
}
