import 'package:freezed_annotation/freezed_annotation.dart';

part 'delete_food_menu_response.freezed.dart';
part 'delete_food_menu_response.g.dart';

@freezed
class DeleteFoodMenuResponse with _$DeleteFoodMenuResponse {
  const factory DeleteFoodMenuResponse({
    required String message,
  }) = _DeleteFoodMenuResponse;

  factory DeleteFoodMenuResponse.fromJson(Map<String, dynamic> json) =>
      _$DeleteFoodMenuResponseFromJson(json);
}
