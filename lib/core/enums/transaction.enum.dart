enum TransactionServiceType {
  foodOrder('food_order'),
  reservation('reservation');

  final String value;

  const TransactionServiceType(this.value);
}

enum FoodOrderStatus {
  pending,
  rejected,
  preparing,
  ready,
  completed
}

enum ReservationStatus {
  pending,
  confirmed,
  cancelled,
  completed,
}

enum TransactionStatus{
  success,
  failed,
  ongoing,
  refunded,
}