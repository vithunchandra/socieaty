import 'package:freezed_annotation/freezed_annotation.dart';

part 'setup_livestream_form_state.freezed.dart';
part 'setup_livestream_form_state.g.dart';

@freezed
class SetupLivestreamFormState with _$SetupLivestreamFormState {
  const factory SetupLivestreamFormState({
    @Default("") String roomTitle,
  }) = _SetupLivestreamFormState;

  factory SetupLivestreamFormState.fromJson(Map<String, dynamic> json) => _$SetupLivestreamFormStateFromJson(json);
}
