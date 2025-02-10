import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_restaurant_menu_form_state.freezed.dart';
part 'update_restaurant_menu_form_state.g.dart';

@freezed
class UpdateRestaurantMenuFormState with _$UpdateRestaurantMenuFormState {
  const factory UpdateRestaurantMenuFormState({
    @Default(null) String? name,
    @Default(null) String? description,
    @Default(0) int price,
    @Default(0) int estimatedTime,
    @Default([]) List<int> categories,
  }) = _UpdateRestaurantMenuFormState;

  factory UpdateRestaurantMenuFormState.fromJson(Map<String, dynamic> json) => _$UpdateRestaurantMenuFormStateFromJson(json);
}
