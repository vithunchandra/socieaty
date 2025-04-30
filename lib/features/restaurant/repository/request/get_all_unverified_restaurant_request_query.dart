import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_all_unverified_restaurant_request_query.freezed.dart';
part 'get_all_unverified_restaurant_request_query.g.dart';

@freezed
class GetAllUnverifiedRestaurantRequestQuery with _$GetAllUnverifiedRestaurantRequestQuery {
  const factory GetAllUnverifiedRestaurantRequestQuery({
    @Default(null) String? name,
    @Default([]) List<int> themes,
  }) = _GetAllUnverifiedRestaurantRequestQuery;

  factory GetAllUnverifiedRestaurantRequestQuery.fromJson(Map<String, dynamic> json) =>
      _$GetAllUnverifiedRestaurantRequestQueryFromJson(json);
}
