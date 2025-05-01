import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';
import 'package:socieaty/features/restaurant/repository/request/update_restaurant_data_request.dart';
import 'package:socieaty/features/restaurant/repository/response/update_restaurant_data_response.dart';
import 'package:socieaty/features/restaurant/repository/restaurant_respository.dart';
import 'package:socieaty/features/restaurant/viewstate/update_restaurant_view_state.dart';
import 'package:socieaty/shared/view_state.dart';

part 'update_restaurant_data_view_model.g.dart';

@riverpod
class UpdateRestaurantDataViewModel extends _$UpdateRestaurantDataViewModel {
  late RestaurantRespository _restaurantRepository;

  @override
  UpdateRestaurantViewState build() {
    _restaurantRepository = ref.watch(restaurantRespositoryProvider);
    return UpdateRestaurantViewState(updateRestaurantDataState: IdleState());
  }

  Future<void> updateRestaurantData(
    SocieatyRestaurant restaurant,
    UpdateRestaurantDataRequest data,
    File? profilePicture,
    File? restaurantBanner,
  ) async {
    state = UpdateRestaurantViewState(updateRestaurantDataState: LoadingState());
    final result = await _restaurantRepository.updateRestaurantData(
      restaurant,
      data,
      profilePicture,
      restaurantBanner,
    );
    switch (result) {
      case Success<UpdateRestaurantDataResponse>(data: final data):
        state = UpdateRestaurantViewState(
            updateRestaurantDataState: SuccessState(data: data.restaurant));
      case Error(error: final error):
        state = UpdateRestaurantViewState(
            updateRestaurantDataState: ErrorState(message: error.message));
    }
  }
}
