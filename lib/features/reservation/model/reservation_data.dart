import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/menu_item/model/menu_item.dart';
import 'package:socieaty/features/reservation/enum/reservation_status_enum.dart';

part 'reservation_data.freezed.dart';
part 'reservation_data.g.dart';

@freezed
class ReservationData with _$ReservationData {
  const factory ReservationData({
    required String reservationId,
    @ReservationStatusConverter() required ReservationStatus reservationStatus,
    @DateTimeConverter() required DateTime reservationTime,
    @DateTimeConverter() required DateTime endTimeEstimation,
    required int peopleSize,
    required List<MenuItem> menuItems,
  }) = _ReservationData;

  factory ReservationData.fromJson(Map<String, dynamic> json) => _$ReservationDataFromJson(json);
}
