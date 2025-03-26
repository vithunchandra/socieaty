import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/features/reservation/model/reservation.dart';

part 'new_reservation_notification_provider.g.dart';

@Riverpod(keepAlive: true)
class NewReservationNotification extends _$NewReservationNotification {
  @override
  Reservation? build() {
    return null;
  }

  void setNewReservation(Reservation reservation) {
    state = reservation;
  }

  void resetNotification() {
    state = null;
  }
}
