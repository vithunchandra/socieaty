import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';
import 'package:socieaty/shared/view_state.dart';

part 'update_restaurant_view_state.freezed.dart';

@freezed
class UpdateRestaurantViewState with _$UpdateRestaurantViewState {
  const factory UpdateRestaurantViewState({
    required ViewState<SocieatyRestaurant> updateRestaurantDataState,
  }) = _UpdateRestaurantViewState;
}
