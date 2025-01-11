import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_screen_view_state.freezed.dart';

@freezed
class HomeScreenViewState with _$HomeScreenViewState {
  const factory HomeScreenViewState({
    required String currentPostId,
  }) = _HomeScreenViewState;
}
