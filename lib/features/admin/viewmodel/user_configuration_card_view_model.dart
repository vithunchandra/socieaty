import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/admin/viewstate/user_configuration_card_view_state.dart';
import 'package:socieaty/features/user/repository/user_repository.dart';
import 'package:socieaty/shared/view_state.dart';

part 'user_configuration_card_view_model.g.dart';

@riverpod
class UserConfigurationCardViewModel extends _$UserConfigurationCardViewModel {
  late UserRepository _userRepository;
  @override
  UserConfigurationCardViewState build(String userId) {
    _userRepository = ref.watch(userRepositoryProvider);
    return UserConfigurationCardViewState(userId: userId, userData: IdleState());
  }

  Future<void> deleteUser() async {
    state = state.copyWith(userData: LoadingState());
    final result = await _userRepository.deleteUser(state.userId);
    switch (result) {
      case Success(data: final data):
        state = state.copyWith(userData: SuccessState(data: data));
      case Error(error: final error):
        state = state.copyWith(userData: ErrorState(message: error.message));
    }
  }

  Future<void> undeleteUser() async {
    state = state.copyWith(userData: LoadingState());
    final result = await _userRepository.undeleteUser(state.userId);
    switch (result) {
      case Success(data: final data):
        state = state.copyWith(userData: SuccessState(data: data));
      case Error(error: final error):
        state = state.copyWith(userData: ErrorState(message: error.message));
    }
  }
}
