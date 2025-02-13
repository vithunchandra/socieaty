import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_food_menu_form_state.freezed.dart';
part 'update_food_menu_form_state.g.dart';

@freezed
class UpdateFoodMenuFormState with _$UpdateFoodMenuFormState {
  const factory UpdateFoodMenuFormState({
    @Default(null) String? name,
    @Default(null) String? description,
    @Default(0) int price,
    @Default(0) int estimatedTime,
    @Default([]) List<int> categories,
  }) = _UpdateFoodMenuFormState;

  factory UpdateFoodMenuFormState.fromJson(Map<String, dynamic> json) =>
      _$UpdateFoodMenuFormStateFromJson(json);
}
