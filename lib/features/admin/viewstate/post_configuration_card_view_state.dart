import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/shared/view_state.dart';

part 'post_configuration_card_view_state.freezed.dart';

@freezed
class PostConfigurationCardViewState with _$PostConfigurationCardViewState {
  const factory PostConfigurationCardViewState({
    required String postId,
    required ViewState<String> deleteResponse,
  }) = _PostConfigurationCardViewState;
}
