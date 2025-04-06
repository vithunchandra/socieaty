import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/topup/model/topup.dart';
import 'package:socieaty/features/topup/repository/response/topup_response.dart';
import 'package:socieaty/shared/view_state.dart';

part 'topup_bottom_sheet_view_state.freezed.dart';

@freezed
class TopupBottomSheetViewState with _$TopupBottomSheetViewState {
  const factory TopupBottomSheetViewState({
    required ViewState<TopupResponse> createdTopup,
  }) = _TopupBottomSheetViewState;

}
