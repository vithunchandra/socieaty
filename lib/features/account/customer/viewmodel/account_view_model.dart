import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/account/customer/viewstate/account_view_state.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/restaurant/provider/get_restaurant_reservation_config_provider.dart';
import 'package:socieaty/shared/view_state.dart';

part 'account_view_model.g.dart';

@riverpod
class AccountViewModel extends _$AccountViewModel {
  late AuthLocalRepository _authLocalRepository;

  @override
  AccountViewState build() {
    _authLocalRepository = ref.watch(authLocalRepositoryProvider);
    return AccountViewState(isSignedOut: IdleState());
  }

  Future<void> signout() async {
    state = state.copyWith(isSignedOut: LoadingState());
    final isSignedOut = await _authLocalRepository.removeToken();
    if (isSignedOut) {
      state = state.copyWith(isSignedOut: SuccessState(data: true));
    } else {
      state = state.copyWith(isSignedOut: ErrorState(message: "Session not found"));
    }
  }
}
