import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/shared/view_state.dart';

part 'livestream_configuration_card_view_state.freezed.dart';

@freezed
class LivestreamConfigurationCardViewState with _$LivestreamConfigurationCardViewState {
  const factory LivestreamConfigurationCardViewState({
    required String roomName,
    required ViewState<bool> isDeletedState,
  }) = _LivestreamConfigurationCardViewState;
}
