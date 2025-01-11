import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/features/home/customer/viewstate/home_screen_view_state.dart';

part 'home_screen_view_model.g.dart';

@riverpod
class HomeScreenViewModel extends _$HomeScreenViewModel {
  @override
  HomeScreenViewState build() {
    return HomeScreenViewState(currentPostId: "");
  }

  void setCurrentPostId(String currentPostId) {
    state = state.copyWith(currentPostId: currentPostId);
  }
}
