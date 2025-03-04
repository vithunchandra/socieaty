import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/network/websocket_client.dart';
import 'package:socieaty/core/notifications/local_notification_service.dart';
import 'package:socieaty/core/utils/show_new_order_dialog.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/transaction/model/food_order_transaction.dart';
import 'package:socket_io_client/socket_io_client.dart';

part 'restaurant_socket_service.g.dart';

@Riverpod(keepAlive: true)
RestaurantSocketService restaurantSocketService(Ref ref) {
  final AuthLocalRepository authLocalRepository = ref.watch(authLocalRepositoryProvider);
  final token = authLocalRepository.getToken();
  return RestaurantSocketService(
    socket:
        ref.watch(websocketClientProvider('${AppConstants.socieatyBackendUrl}food-order', token)),
    notificationService: ref.watch(localNotificationServiceProvider),
  );
}

class RestaurantSocketService {
  Socket socket;
  bool _isConnected = false;
  final LocalNotificationService notificationService;

  RestaurantSocketService({required this.socket, required this.notificationService});

  bool get isConnected => _isConnected;

  initConnection() {
    debugPrint("TEst");
    if (_isConnected) return;

    notificationService.init();

    socket.connect();
    socket.on('connection', (_) {
      debugPrint('connect ${_.toString()}');
    });

    debugPrint('Trying Connection');
    socket.onConnect((_) {
      debugPrint('Restaurant connected to server');
      _isConnected = true;
    });

    socket.onDisconnect((_) {
      debugPrint('Restaurant disconnected from server');
      _isConnected = false;
    });

    socket.onerror((_) {
      debugPrint('Error Is ${_.toString()}');
      _isConnected = false;
    });
  }

  void disconnect() {
    socket.disconnect();
    _isConnected = false;
  }

  void listenNewOrder(Function(dynamic) onNewOrder) {
    socket.on('new-order', (data) {
      debugPrint('New Order Received: $data');

      try {
        final FoodOrderTransaction orderData = FoodOrderTransaction.fromJson(data);

        showNewOrderDialog(orderData);

        final formattedTotal = _formatCurrency(orderData.grossAmount + orderData.serviceFee);

        final customerName = orderData.customer.name;

        final int itemCount = orderData.menuItems.length;
        final String itemsText = _getItemsDescription(orderData);

        String notificationTitle = '💰 New Order #${orderData.id.substring(0, 8)}';

        String notificationBody = '''
          <b>$customerName</b> placed a new order
          💵 <b>Total:</b> \$$formattedTotal
          🍽️ <b>Items:</b> $itemCount item${itemCount != 1 ? 's' : ''}
          $itemsText

          <i>Tap to view order details</i>
        ''';

        notificationService.showNewOrderNotification(
          title: notificationTitle,
          body: notificationBody,
          payload: orderData,
          orderDetails: orderData.toJson(),
        );

        onNewOrder(data);
      } catch (e) {
        debugPrint('Error processing new order: $e');

        notificationService.showNewOrderNotification(
          title: '💰 New Restaurant Order',
          body: 'You have received a new order. Tap to view details.',
        );

        onNewOrder(data);
      }
    });
  }

  String _formatCurrency(int amount) {
    final double value = amount / 100;

    final String formatted = value
        .toStringAsFixed(2)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

    return formatted;
  }

  String _getItemsDescription(FoodOrderTransaction order) {
    if (order.menuItems.isEmpty) {
      return '';
    }

    final itemsToShow = order.menuItems.take(3);

    final StringBuffer buffer = StringBuffer();

    for (final item in itemsToShow) {
      final String itemName = item.menu.name;
      final int quantity = item.quantity;

      buffer.writeln('• $quantity x $itemName');
    }

    if (order.menuItems.length > 3) {
      buffer.writeln(
          '• ... and ${order.menuItems.length - 3} more item${order.menuItems.length - 3 > 1 ? 's' : ''}');
    }

    return buffer.toString();
  }

  void removeListener(String event) {
    socket.off(event);
  }
}
