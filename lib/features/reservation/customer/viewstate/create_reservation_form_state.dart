import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/menu_item/model/menu_cart_item.dart';

part 'create_reservation_form_state.freezed.dart';
part 'create_reservation_form_state.g.dart';

@freezed
class CreateReservationFormState with _$CreateReservationFormState {
  const factory CreateReservationFormState({
    required String restaurantId,
    @DateTimeConverter() required DateTime reservationTime,
    required int peopleSize,
    required String note,
    required List<MenuCartItem> menuItems,
  }) = _CreateReservationFormState;

  factory CreateReservationFormState.fromJson(Map<String, dynamic> json) =>
      _$CreateReservationFormStateFromJson(json);
}
