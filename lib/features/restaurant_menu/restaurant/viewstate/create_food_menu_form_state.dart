import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_food_menu_form_state.freezed.dart';
part 'create_food_menu_form_state.g.dart';

@freezed
class CreateFoodMenuFormState with _$CreateFoodMenuFormState {
  const factory CreateFoodMenuFormState({
    @Default(null) String? name,
    @Default(null) String? description,
    @Default(0) int price,
    @Default(0) int estimatedTime,
    @Default([]) List<int> categories,
  }) = _CreateFoodMenuFormState;

  factory CreateFoodMenuFormState.fromJson(Map<String, dynamic> json) =>
      _$CreateFoodMenuFormStateFromJson(json);
}
