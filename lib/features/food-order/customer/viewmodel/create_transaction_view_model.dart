import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/food-order/customer/viewstate/create_food_order_form_state.dart';
import 'package:socieaty/features/food-order/customer/viewstate/create_food_order_view_state.dart';
import 'package:socieaty/features/food-order/repository/food_order_repository.dart';
import 'package:socieaty/shared/view_state.dart';

part 'create_transaction_view_model.g.dart';

@riverpod
class CreateTransactionViewModel extends _$CreateTransactionViewModel {
  late FoodOrderRepository _transactionRepository;

  @override
  CreateFoodOrderViewState build() {
    _transactionRepository = ref.watch(foodOrderRepositoryProvider);
    return CreateFoodOrderViewState(formState: IdleState());
  }

  Future<void> createTransaction(CreateFoodOrderFormState formState) async {
    state = state.copyWith(formState: LoadingState());
    final result = await _transactionRepository.createOrderTransaction(formState);
    switch (result) {
      case Success(data: final data):
        state = state.copyWith(formState: SuccessState(data: data.transaction));
      case Error(error: final error):
        state = state.copyWith(formState: ErrorState(message: error.message));
    }
  }
}
