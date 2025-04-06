import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/topup/repository/topup_repository.dart';
import 'package:socieaty/features/topup/viewstate/topup_bottom_sheet_view_state.dart';
import 'package:socieaty/shared/view_state.dart';

part 'topup_bottom_sheet_view_model.g.dart';

@riverpod
class TopupBottomSheetViewModel extends _$TopupBottomSheetViewModel {
  @override
  TopupBottomSheetViewState build() {
    return TopupBottomSheetViewState(createdTopup: IdleState());
  }

  Future<void> createTopup(double amount) async {
    state = state.copyWith(createdTopup: LoadingState());
    final result = await ref.read(topupRepositoryProvider).createTopup(amount);
    switch (result) {
      case Success(data: var data):
        state = state.copyWith(createdTopup: SuccessState(data: data));
      case Error(error: var error):
        state = state.copyWith(createdTopup: ErrorState(message: error.message));
    }
  }
}
