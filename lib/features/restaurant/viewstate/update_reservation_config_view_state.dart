import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/restaurant/model/reservation_config.dart';
import 'package:socieaty/shared/view_state.dart';

part 'update_reservation_config_view_state.freezed.dart';

@freezed
class UpdateReservationConfigViewState with _$UpdateReservationConfigViewState {
  const factory UpdateReservationConfigViewState({
    required ViewState<ReservationConfig> updateReservationConfigState,
  }) = _UpdateReservationConfigViewState;
}
