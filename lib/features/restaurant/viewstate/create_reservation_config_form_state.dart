import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_reservation_config_form_state.freezed.dart';
part 'create_reservation_config_form_state.g.dart';

@freezed
class CreateReservationConfigFormState with _$CreateReservationConfigFormState {
  const factory CreateReservationConfigFormState({
    required int maxPerson,
    required int minCostPerPerson,
    required int timeLimit,
    required List<String> facilities,
  }) = _CreateReservationConfigFormState;

  factory CreateReservationConfigFormState.fromJson(Map<String, dynamic> json) =>
      _$CreateReservationConfigFormStateFromJson(json);
}
