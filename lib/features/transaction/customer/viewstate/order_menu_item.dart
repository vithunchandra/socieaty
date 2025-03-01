import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_menu_item.freezed.dart';
part 'order_menu_item.g.dart';

@freezed
class OrderMenuItem with _$OrderMenuItem {
  const factory OrderMenuItem({
    required String menuId,
    required int quantity,
  }) = _OrderMenuItem;

  factory OrderMenuItem.fromJson(Map<String, dynamic> json) => _$OrderMenuItemFromJson(json);
}
