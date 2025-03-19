import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/restaurant/model/reservation_config.dart';
import 'package:socieaty/shared/view_state.dart';

part 'create_reservation_config_view_state.freezed.dart';

@freezed
class CreateReservationConfigViewState with _$CreateReservationConfigViewState {
  const factory CreateReservationConfigViewState({
    required ViewState<ReservationConfig> createReservationConfigState,
  }) = _CreateReservationConfigViewState;
}
