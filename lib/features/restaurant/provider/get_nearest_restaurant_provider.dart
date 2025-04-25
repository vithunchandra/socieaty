import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';
import 'package:socieaty/features/restaurant/repository/request/get_nearest_restaurant_request_query.dart';
import 'package:socieaty/features/restaurant/repository/restaurant_respository.dart';

part 'get_nearest_restaurant_provider.g.dart';

@riverpod
Future<List<SocieatyRestaurant>> getNearestRestaurant(
  Ref ref,
  GetNearestRestaurantRequestQuery query,
) async {
  final repository = ref.watch(restaurantRespositoryProvider);
  final result = await repository.getNearestRestaurant(query);
  switch (result) {
    case Success(data: final data):
      return data.restaurants;
    case Error(error: final error):
      throw Exception(error.message);
  }
}
