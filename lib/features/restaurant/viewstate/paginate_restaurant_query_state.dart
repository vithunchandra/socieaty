import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/shared/models/pagination_query.dart';

part 'paginate_restaurant_query_state.freezed.dart';
part 'paginate_restaurant_query_state.g.dart';

@freezed
class PaginateRestaurantQueryState with _$PaginateRestaurantQueryState {
  const factory PaginateRestaurantQueryState({
    @Default(PaginationQuery(offset: 0, limit: 5)) PaginationQuery paginationQuery,
    @Default(null) String? name,
    @Default([]) List<String> priceRanges,
    @Default([]) List<int> foodCategories,
    @Default([]) List<int> themes,
    @Default(0) double minRating,
  }) = _PaginateRestaurantQueryState;

  factory PaginateRestaurantQueryState.fromJson(Map<String, dynamic> json) =>
      _$PaginateRestaurantQueryStateFromJson(json);
}
