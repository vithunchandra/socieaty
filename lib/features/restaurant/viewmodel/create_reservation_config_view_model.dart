import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/restaurant/repository/restaurant_respository.dart';
import 'package:socieaty/features/restaurant/viewstate/create_reservation_config_form_state.dart';
import 'package:socieaty/features/restaurant/viewstate/create_reservation_config_view_state.dart';
import 'package:socieaty/shared/view_state.dart';

part 'create_reservation_config_view_model.g.dart';

@riverpod
class CreateReservationConfigViewModel extends _$CreateReservationConfigViewModel {
  late RestaurantRespository restaurantRepository;

  @override
  CreateReservationConfigViewState build() {
    restaurantRepository = ref.watch(restaurantRespositoryProvider);
    return CreateReservationConfigViewState(
      createReservationConfigState: IdleState(),
    );
  }

  createReservationConfig(CreateReservationConfigFormState formState) async {
    state = state.copyWith(createReservationConfigState: LoadingState());
    final result = await restaurantRepository.createReservationConfig(formState);
    switch (result) {
      case Success(data: final data):
        state = state.copyWith(
            createReservationConfigState: SuccessState(data: data.reservationConfig));
      case Error(error: final error):
        state = state.copyWith(createReservationConfigState: ErrorState(message: error.message));
    }
  }
}
