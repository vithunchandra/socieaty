import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/restaurant/repository/restaurant_respository.dart';
import 'package:socieaty/features/restaurant/viewstate/update_reservation_config_form_state.dart';
import 'package:socieaty/features/restaurant/viewstate/update_reservation_config_view_state.dart';
import 'package:socieaty/shared/view_state.dart';

part 'update_reservation_config_view_model.g.dart';

@riverpod
class UpdateReservationConfigViewModel extends _$UpdateReservationConfigViewModel {
  late RestaurantRespository restaurantRepository;

  @override
  UpdateReservationConfigViewState build() {
    restaurantRepository = ref.watch(restaurantRespositoryProvider);
    return UpdateReservationConfigViewState(
      updateReservationConfigState: IdleState(),
    );
  }

  updateReservationConfig(UpdateReservationConfigFormState formState) async {
    state = state.copyWith(updateReservationConfigState: LoadingState());
    final result = await restaurantRepository.updateReservationConfig(formState);
    switch (result) {
      case Success(data: final data):
        state =
            state.copyWith(updateReservationConfigState: SuccessState(data: data.updatedConfig));
      case Error(error: final error):
        state = state.copyWith(updateReservationConfigState: ErrorState(message: error.message));
    }
  }
}
