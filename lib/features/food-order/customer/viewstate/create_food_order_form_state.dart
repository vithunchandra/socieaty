import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/food-order/customer/viewstate/order_menu_item.dart';

part 'create_food_order_form_state.freezed.dart';
part 'create_food_order_form_state.g.dart';

@freezed
class CreateFoodOrderFormState with _$CreateFoodOrderFormState {
  const factory CreateFoodOrderFormState({
    required String restaurantId,
    @TransactionServiceTypeConverter() required TransactionServiceType serviceType,
    @Default([]) List<OrderMenuItem> menuItems,
    @Default('') String note,
  }) = _CreateFoodOrderFormState;

  factory CreateFoodOrderFormState.fromJson(Map<String, dynamic> json) =>
      _$CreateFoodOrderFormStateFromJson(json);
}
