import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';
import 'package:socieaty/shared/models/pagination.dart';

part 'restaurant_pagination.freezed.dart';
part 'restaurant_pagination.g.dart';

@freezed
class RestaurantPagination with _$RestaurantPagination {
  const factory RestaurantPagination({
    required List<SocieatyRestaurant> restaurants,
    required Pagination pagination,
  }) = _RestaurantPagination;

  factory RestaurantPagination.fromJson(Map<String, dynamic> json) =>
      _$RestaurantPaginationFromJson(json);
}