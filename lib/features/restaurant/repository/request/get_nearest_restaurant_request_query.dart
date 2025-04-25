import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_nearest_restaurant_request_query.freezed.dart';
part 'get_nearest_restaurant_request_query.g.dart';

@freezed
class GetNearestRestaurantRequestQuery with _$GetNearestRestaurantRequestQuery {
  const factory GetNearestRestaurantRequestQuery({
    required double latitude,
    required double longitude,
    required double radius,
  }) = _GetNearestRestaurantRequestQuery;

  factory GetNearestRestaurantRequestQuery.fromJson(Map<String, dynamic> json) =>
      _$GetNearestRestaurantRequestQueryFromJson(json);
}
