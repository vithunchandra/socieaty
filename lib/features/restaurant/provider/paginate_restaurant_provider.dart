import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/restaurant/model/restaurant_pagination.dart';
import 'package:socieaty/features/restaurant/repository/restaurant_respository.dart';
import 'package:socieaty/features/restaurant/viewstate/paginate_restaurant_query_state.dart';

part 'paginate_restaurant_provider.g.dart';

@riverpod
Future<RestaurantPagination> paginateRestaurant(Ref ref, PaginateRestaurantQueryState query) async {
  final repository = ref.watch(restaurantRespositoryProvider);
  final result = await repository.paginateRestaurants(query);
  switch (result) {
    case Success(data: final data):
      return RestaurantPagination(
        restaurants: data.restaurants.map((restaurant) => UserConverter.userToRestaurant(restaurant)).toList(),
        pagination: data.pagination,
      );
    case Error(error: final error):
      throw error;
  }
}


