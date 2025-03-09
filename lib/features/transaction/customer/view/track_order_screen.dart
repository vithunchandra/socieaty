import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/transaction/customer/socket/customer_socket_service.dart';
import 'package:socieaty/features/transaction/model/food_order_transaction.dart';
import 'package:socieaty/features/transaction/repository/transaction_repository.dart';
import 'package:socieaty/features/transaction/customer/view/states/active_order_view.dart';
import 'package:socieaty/features/transaction/customer/view/states/completed_order_screen.dart';
import 'package:socieaty/features/transaction/customer/view/states/error_view.dart';
import 'package:socieaty/features/transaction/customer/view/states/generic_error_view.dart';
import 'package:socieaty/features/transaction/customer/view/states/loading_view.dart';
import 'package:socieaty/features/transaction/customer/view/states/rejected_order_screen.dart';

class TrackOrderScreen extends ConsumerStatefulWidget {
  final String orderId;

  const TrackOrderScreen({
    super.key,
    required this.orderId,
  });

  @override
  ConsumerState<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends ConsumerState<TrackOrderScreen> {
  late CustomerSocketService _socketService;
  FoodOrderTransaction? _orderData;
  bool _isLoading = true;
  String? _errorMessage;

  // For controlling the scroll behavior
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initialize socket service
    _socketService = ref.read(customerSocketServiceProvider);

    // Setup socket listeners after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupSocketListeners();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _removeSocketListeners();
    super.dispose();
  }

  void _setupSocketListeners() {
    _socketService.initConnection();
    _socketService.listenOrderUpdate(widget.orderId, _handleOrderUpdate);
    ref.read(transactionRepositoryProvider).trackOrderTransaction(widget.orderId).then((value) {
      switch (value) {
        case Success(data: final data):
          debugPrint('Order tracked: ${data.message}');
        case Error(error: final error):
          debugPrint('Error tracking order: $error');
      }
    });
  }

  void _removeSocketListeners() {
    _socketService.removeListener('track-order');
  }

  void _handleOrderUpdate(dynamic data) {
    debugPrint('Received order update: $data');

    try {
      final updatedOrder = FoodOrderTransaction.fromJson(data);

      // Only update if this is for our order
      if (updatedOrder.id == widget.orderId) {
        if (mounted) {
          setState(() {
            _orderData = updatedOrder;
            _isLoading = false;
            _errorMessage = null;
          });
        }
      }
    } catch (e) {
      debugPrint('Error processing order update: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Error processing order data';
          _isLoading = false;
        });
      }
    }
  }

  // Navigate to map screen
  void _navigateToMapScreen() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Map screen will be implemented separately'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleRetry() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _setupSocketListeners();
  }

  void _showRateRestaurantDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rate restaurant feature will be implemented separately'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showContactSupportDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Customer support feature will be implemented separately'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.neutralColor.shade50,
      appBar: AppBar(
        backgroundColor: AppPallete.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Track Order #${widget.orderId.substring(0, 8)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildBodyContent(),
    );
  }

  /// Builds the appropriate body content based on the current state.
  Widget _buildBodyContent() {
    // Loading state
    if (_isLoading) {
      return const LoadingView();
    }

    // Error state
    if (_errorMessage != null && _orderData == null) {
      return ErrorView(
        errorMessage: _errorMessage ?? 'Unable to load order data',
        onRetry: _handleRetry,
      );
    }

    // Null check for order data
    if (_orderData == null) {
      return GenericErrorView(
        onBackPressed: () => Navigator.of(context).pop(),
      );
    }

    // Return appropriate view based on order status
    switch (_orderData!.status) {
      case TransactionStatus.pending:
      case TransactionStatus.preparing:
      case TransactionStatus.ready:
        return ActiveOrderView(
          order: _orderData!,
          scrollController: _scrollController,
          navigateToMapScreen: _navigateToMapScreen,
        );

      case TransactionStatus.completed:
        return CompletedOrderScreen(
          order: _orderData!,
          onBackToHome: () => context.pop(),
          onRateRestaurant: _showRateRestaurantDialog,
        );

      case TransactionStatus.rejected:
        return RejectedOrderScreen(
          order: _orderData!,
          onBackToHome: () => context.pop(),
          onContactSupport: _showContactSupportDialog,
        );
    }
  }
}
