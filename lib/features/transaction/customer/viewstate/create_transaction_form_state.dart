import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/transaction/customer/viewstate/order_menu_item.dart';

part 'create_transaction_form_state.freezed.dart';
part 'create_transaction_form_state.g.dart';

@freezed
class CreateTransactionFormState with _$CreateTransactionFormState {
  const factory CreateTransactionFormState({
    required String restaurantId,
    @TransactionServiceTypeConverter() required TransactionServiceType serviceType,
    @Default([]) List<OrderMenuItem> menuItems,
    @Default('') String additionalNotes,
  }) = _CreateTransactionFormState;

  factory CreateTransactionFormState.fromJson(Map<String, dynamic> json) =>
      _$CreateTransactionFormStateFromJson(json);
}

