import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/reservation/customer/viewstate/create_reservation_form_state.dart';
import 'package:socieaty/features/reservation/customer/viewstate/create_reservation_view_state.dart';
import 'package:socieaty/features/reservation/repository/reservation_repository.dart';
import 'package:socieaty/shared/view_state.dart';

part 'create_reservation_viewmodel.g.dart';

@riverpod
class CreateReservationViewModel extends _$CreateReservationViewModel{

  late ReservationRepository _reservationRepository;
  @override
  CreateReservationViewState build() {
    _reservationRepository = ref.watch(reservationRepositoryProvider);
    return CreateReservationViewState(createdReservation: IdleState());
  }

  Future<void> createReservation(CreateReservationFormState formState) async {
    state = state.copyWith(createdReservation: LoadingState());
    final result = await _reservationRepository.createReservation(formState);
    switch (result) {
      case Success(data: final data):
        state = state.copyWith(createdReservation: SuccessState(data: data.reservation));
      case Error(error: final error):
        state = state.copyWith(createdReservation: ErrorState(message: error.message));
    }
  }
}