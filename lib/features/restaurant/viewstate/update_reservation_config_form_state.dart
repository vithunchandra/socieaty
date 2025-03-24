import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_reservation_config_form_state.freezed.dart';
part 'update_reservation_config_form_state.g.dart';

@freezed
class UpdateReservationConfigFormState with _$UpdateReservationConfigFormState {
  const factory UpdateReservationConfigFormState({
    required String id,
    required int maxPerson,
    required int minCostPerPerson,
    required int timeLimit,
    required List<String> facilities,
  }) = _UpdateReservationConfigFormState;

  factory UpdateReservationConfigFormState.fromJson(Map<String, dynamic> json) =>
      _$UpdateReservationConfigFormStateFromJson(json);
}
