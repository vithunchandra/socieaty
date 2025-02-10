import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_restaurant_menu_form_state.freezed.dart';
part 'create_restaurant_menu_form_state.g.dart';

@freezed
class CreateRestaurantMenuFormState with _$CreateRestaurantMenuFormState {
  const factory CreateRestaurantMenuFormState({
    @Default(null) String? name,
    @Default(null) String? description,
    @Default(0) int price,
    @Default(0) int estimatedTime,
    @Default([]) List<int> categories,
  }) = _CreateRestaurantMenuFormState;

  factory CreateRestaurantMenuFormState.fromJson(Map<String, dynamic> json) =>
      _$CreateRestaurantMenuFormStateFromJson(json);
}
