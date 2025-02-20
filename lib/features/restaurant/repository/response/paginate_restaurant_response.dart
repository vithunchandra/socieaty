import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';
import 'package:socieaty/shared/models/pagination.dart';

part 'paginate_restaurant_response.freezed.dart';
part 'paginate_restaurant_response.g.dart';

@freezed
class PaginateRestaurantResponse with _$PaginateRestaurantResponse {
  const factory PaginateRestaurantResponse({
    required List<SocieatyUser> restaurants,
    required Pagination pagination,
  }) = _PaginateRestaurantResponse;

  factory PaginateRestaurantResponse.fromJson(Map<String, dynamic> json) =>
      _$PaginateRestaurantResponseFromJson(json);
}
