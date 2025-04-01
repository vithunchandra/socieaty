import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/features/reservation/model/reservation.dart';

part 'reservation_changes_notification_provider.g.dart';

@Riverpod(keepAlive: true)
class ReservationChangesNotification extends _$ReservationChangesNotification {
  @override
  Reservation? build() {
    return null;
  }

  void setReservationChanges(Reservation reservation) {
    state = reservation;
  }

  void resetNotification() {
    state = null;
  }
}
