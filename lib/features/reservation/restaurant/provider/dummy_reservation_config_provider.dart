import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/features/restaurant/model/reservation_config.dart';

part 'dummy_reservation_config_provider.g.dart';

@riverpod
ReservationConfig dummyReservationConfig(DummyReservationConfigRef ref) {
  return const ReservationConfig(
    id: 'dummy-id',
    restaurantId: 'dummy-restaurant-id',
    maxPerson: 8,
    minCostPerPerson: 50000,
    timeLimit: 120,
    facilities: ['WiFi', 'Parking', 'Outdoor Seating'],
  );
}
