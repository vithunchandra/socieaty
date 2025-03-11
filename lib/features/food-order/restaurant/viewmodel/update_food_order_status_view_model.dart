import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/food-order/repository/food_order_repository.dart';
import 'package:socieaty/features/food-order/restaurant/viewstate/update_food_order_status_view_state.dart';
import 'package:socieaty/shared/view_state.dart';

part 'update_food_order_status_view_model.g.dart';

@riverpod
class UpdateFoodOrderStatusViewModel extends _$UpdateFoodOrderStatusViewModel {
  late FoodOrderRepository _transactionRepository;

  @override
  UpdateFoodOrderStatusViewState build(String orderId) {
    _transactionRepository = ref.read(foodOrderRepositoryProvider);
    return UpdateFoodOrderStatusViewState(
      orderId: orderId,
      updatedOrder: IdleState(),
    );
  }

  Future<void> updateTransactionStatus(FoodOrderStatus newStatus) async {
    state = state.copyWith(updatedOrder: LoadingState());

    final result = await _transactionRepository.updateTransactionStatus(orderId, newStatus);

    switch (result) {
      case Success(data: var data):
        state = state.copyWith(updatedOrder: SuccessState(data: data.transaction));
      case Error(error: var error):
        state = state.copyWith(updatedOrder: ErrorState(message: error.message));
    }
  }
}
