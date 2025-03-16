import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_restaurant_reviews_query.freezed.dart';
part 'get_restaurant_reviews_query.g.dart';

@freezed
class GetRestaurantReviewsQuery with _$GetRestaurantReviewsQuery {
  const factory GetRestaurantReviewsQuery({
    required int rating,
  }) = _GetRestaurantReviewsQuery;

  factory GetRestaurantReviewsQuery.fromJson(Map<String, dynamic> json) =>
      _$GetRestaurantReviewsQueryFromJson(json);
}
