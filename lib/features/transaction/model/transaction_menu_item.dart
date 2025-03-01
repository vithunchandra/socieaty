import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/features/food_menu/model/food_menu.dart';

part 'transaction_menu_item.freezed.dart';
part 'transaction_menu_item.g.dart';

@freezed
class TransactionMenuItem with _$TransactionMenuItem {
  const factory TransactionMenuItem({
    required String id,
    required FoodMenu menu,
    required int quantity,
    required int price,
    required int totalPrice,
  }) = _TransactionMenuItem;

  factory TransactionMenuItem.fromJson(Map<String, dynamic> json) => _$TransactionMenuItemFromJson(json);
}

