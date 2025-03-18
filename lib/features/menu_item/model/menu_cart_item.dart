import 'package:freezed_annotation/freezed_annotation.dart';

part 'menu_cart_item.freezed.dart';
part 'menu_cart_item.g.dart';

@freezed
class MenuCartItem with _$MenuCartItem {
  const factory MenuCartItem({
    required String menuId,
    required int quantity,
  }) = _MenuCartItem;

  factory MenuCartItem.fromJson(Map<String, dynamic> json) => _$MenuCartItemFromJson(json);
}
