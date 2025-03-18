import 'package:freezed_annotation/freezed_annotation.dart';

part 'reservation_config.freezed.dart';
part 'reservation_config.g.dart';

@freezed
class ReservationConfig with _$ReservationConfig {
  const factory ReservationConfig({
    required String id,
    required String restaurantId,
    required int maxPerson,
    required int minCostPerPerson,
    required int timeLimit,
    required List<String> facilities,
  }) = _ReservationConfig;

  factory ReservationConfig.fromJson(Map<String, dynamic> json) => _$ReservationConfigFromJson(json);
}