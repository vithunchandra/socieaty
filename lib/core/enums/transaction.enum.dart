enum TransactionServiceType {
  foodOrder('food_order'),
  reservation('reservation');

  final String value;

  const TransactionServiceType(this.value);
}

enum TransactionStatus{
  success,
  failed,
  ongoing,
  refunded,
}