import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/food_menu/model/food_menu.dart';
import 'package:socieaty/shared/models/pagination.dart';

part 'paginate_food_menu_response.freezed.dart';
part 'paginate_food_menu_response.g.dart';

@freezed
class PaginateFoodMenuResponse with _$PaginateFoodMenuResponse {
  const factory PaginateFoodMenuResponse({
    required List<FoodMenu> menu,
    required Pagination pagination,
  }) = _PaginateFoodMenuResponse;

  factory PaginateFoodMenuResponse.fromJson(Map<String, dynamic> json) => _$PaginateFoodMenuResponseFromJson(json);
}