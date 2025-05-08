import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/food-order/enum/food_order_status_enum.dart';
import 'package:socieaty/features/menu_item/model/menu_item.dart';

part 'food_order_data.freezed.dart';
part 'food_order_data.g.dart';

@freezed
class FoodOrderData with _$FoodOrderData {
  const factory FoodOrderData({
    required String orderId,
    @FoodOrderStatusConverter() required FoodOrderStatus foodOrderStatus,
    required List<MenuItem> menuItems,
  }) = _FoodOrderData;

  factory FoodOrderData.fromJson(Map<String, dynamic> json) => _$FoodOrderDataFromJson(json);
}
