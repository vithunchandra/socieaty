import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/restaurant/model/reservation_config.dart';
import 'package:socieaty/features/restaurant/repository/response/get_reservation_config_response.dart';
import 'package:socieaty/features/restaurant/repository/restaurant_respository.dart';

part 'get_restaurant_reservation_config_provider.g.dart';

@riverpod
Future<ReservationConfig?> getRestaurantReservationConfig(Ref ref, String restaurantId) async {
  final RestaurantRespository restaurantRespository = ref.watch(restaurantRespositoryProvider);
  final result = await restaurantRespository.getReservationConfig(restaurantId);
  switch (result) {
    case Success<GetReservationConfigResponse>(data: final data):
      return data.reservationConfig;
    case Error(error: final error):
      throw Exception(error.message);
  }
}
