import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/admin/viewstate/verify_restaurant_view_state.dart';
import 'package:socieaty/features/restaurant/enum/restaurant_verification_status_enum.dart';
import 'package:socieaty/features/restaurant/repository/request/update_restaurant_verification_status_request.dart';
import 'package:socieaty/features/restaurant/repository/response/verify_resturant_account_response.dart';
import 'package:socieaty/features/restaurant/repository/restaurant_respository.dart';
import 'package:socieaty/shared/view_state.dart';

part 'verify_restaurant_view_model.g.dart';

@riverpod
class VerifyRestaurantViewModel extends _$VerifyRestaurantViewModel {
  late RestaurantRespository _restaurantRepository;
  @override
  VerifyRestaurantViewState build(String restaurantId) {
    _restaurantRepository = ref.watch(restaurantRespositoryProvider);
    return VerifyRestaurantViewState(
      restaurantId: restaurantId,
      rejectVerificationState: IdleState(),
      verifyRestaurantState: IdleState(),
    );
  }

  Future<void> rejectVerification() async {
    state = state.copyWith(rejectVerificationState: LoadingState());
    final result = await _restaurantRepository.updateRestaurantVerificationStatus(restaurantId,
        UpdateRestaurantVerificationStatusRequest(status: RestaurantVerificationStatus.rejected));
    debugPrint(result.toString());
    switch (result) {
      case Success<VerifyRestaurantAccountResponse>(data: final data):
        state = state.copyWith(rejectVerificationState: SuccessState(data: data.message));
      case Error(error: final error):
        state = state.copyWith(rejectVerificationState: ErrorState(message: error.message));
    }
  }

  Future<void> acceptVerification() async {
    state = state.copyWith(verifyRestaurantState: LoadingState());
    final result = await _restaurantRepository.updateRestaurantVerificationStatus(restaurantId,
        UpdateRestaurantVerificationStatusRequest(status: RestaurantVerificationStatus.verified));
    debugPrint(result.toString());
    switch (result) {
      case Success<VerifyRestaurantAccountResponse>(data: final data):
        state = state.copyWith(verifyRestaurantState: SuccessState(data: data.message));
      case Error(error: final error):
        state = state.copyWith(verifyRestaurantState: ErrorState(message: error.message));
    }
  }

  void resetStates() {
    state = state.copyWith(
      rejectVerificationState: IdleState(),
      verifyRestaurantState: IdleState(),
    );
  }
}
