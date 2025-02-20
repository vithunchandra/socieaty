import 'package:freezed_annotation/freezed_annotation.dart';

part 'paginate_restaurant_query_state.freezed.dart';
part 'paginate_restaurant_query_state.g.dart';

@freezed
class PaginateRestaurantQueryState with _$PaginateRestaurantQueryState {
  const factory PaginateRestaurantQueryState({
    @Default(0) int offset,
    @Default(5) int limit,
    @Default(null) String? name,
    @Default([]) List<String> priceRanges,
    @Default([]) List<int> foodCategories,
    @Default([]) List<int> themes,
    @Default(0) double minRating,
  }) = _PaginateRestaurantQueryState;

  factory PaginateRestaurantQueryState.fromJson(Map<String, dynamic> json) =>
      _$PaginateRestaurantQueryStateFromJson(json);
}
