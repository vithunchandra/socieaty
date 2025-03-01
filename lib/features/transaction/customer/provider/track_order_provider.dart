import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/features/customer/socket/customer_socket_service.dart';
import 'package:socieaty/features/transaction/model/food_order_transaction.dart';

part 'track_order_provider.g.dart';

@riverpod
Stream<FoodOrderTransaction> trackOrder(Ref ref, {String? orderId}) async* {
  final streamController = StreamController<FoodOrderTransaction>.broadcast();
  final socketService = ref.watch(customerSocketServiceProvider);

  // Initialize connection if needed
  socketService.initConnection();

  socketService.listenOrderUpdate((data) {
    final transaction = FoodOrderTransaction.fromJson(data);

    // If orderId is provided, only emit events for that specific order
    if (orderId == null || transaction.id == orderId) {
      streamController.add(transaction);
    }
  });

  // Register a callback to close the StreamController when the provider is disposed
  ref.onDispose(() {
    streamController.close();
  });

  // Yield values from the stream
  await for (final value in streamController.stream) {
    yield value;
  }
}
