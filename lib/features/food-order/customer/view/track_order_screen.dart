import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/map/view/tracking_map.dart';
import 'package:socieaty/features/food-order/customer/socket/customer_socket_service.dart';
import 'package:socieaty/features/food-order/model/food_order_transaction.dart';
import 'package:socieaty/features/food-order/repository/food_order_repository.dart';
import 'package:socieaty/features/food-order/customer/view/states/active_order_view.dart';
import 'package:socieaty/features/food-order/customer/view/states/completed_order_screen.dart';
import 'package:socieaty/features/food-order/customer/view/states/error_view.dart';
import 'package:socieaty/features/food-order/customer/view/states/generic_error_view.dart';
import 'package:socieaty/features/food-order/customer/view/states/loading_view.dart';
import 'package:socieaty/features/food-order/customer/view/states/rejected_order_screen.dart';
import 'package:socieaty/features/food-order/enum/food_order_status_enum.dart';



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

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _socketService = ref.read(customerSocketServiceProvider);

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
    ref.read(foodOrderRepositoryProvider).trackOrderTransaction(widget.orderId).then((value) {
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

      if (updatedOrder.orderId == widget.orderId) {
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

  void _navigateToMapScreen() async {
    if (_orderData == null) return;

    try {
      // Get the restaurant location from the order data
      // Use fallback coordinates for Jakarta if location not available
      LatLng restaurantLocation;
      try {
        restaurantLocation = _orderData!.restaurant.restaurantData.location;
      } catch (e) {
        // Fallback to central Jakarta coordinates
        restaurantLocation = const LatLng(-6.175110, 106.865036);
      }

      final String restaurantName = _orderData!.restaurant.name;
      final String restaurantAddress = "Lokasi Restoran";

      // Use dummy location data for the customer location
      // This is approximately 500 meters south of the restaurant location
      final LatLng customerLocation = LatLng(
        restaurantLocation.latitude - 0.005,
        restaurantLocation.longitude - 0.002,
      );

      // Navigate to the tracking map screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TrackingMap(
            customerLocation: customerLocation,
            targetLocation: restaurantLocation,
            targetName: restaurantName,
            targetAddress: restaurantAddress,
          ),
        ),
      );
    } catch (e) {
      showSnackbar(context, 'Error opening map: ${e.toString()}', state: SnackbarState.error);
    }
  }

  void _handleRetry() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _setupSocketListeners();
  }

  void _showRateRestaurantDialog() {
    showSnackbar(context, 'Fitur penilaian restoran akan diimplementasikan secara terpisah',
        state: SnackbarState.info);
  }

  void _showContactSupportDialog() {
    showSnackbar(context, 'Fitur layanan pelanggan akan diimplementasikan secara terpisah',
        state: SnackbarState.info);
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
          'Lacak Pesanan #${widget.orderId.substring(0, 8)}',
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

  Widget _buildBodyContent() {
    if (_isLoading) {
      return const LoadingView();
    }

    if (_errorMessage != null && _orderData == null) {
      return ErrorView(
        errorMessage: _errorMessage ?? 'Tidak dapat memuat data pesanan',
        onRetry: _handleRetry,
      );
    }

    if (_orderData == null) {
      return GenericErrorView(
        onBackPressed: () => Navigator.of(context).pop(),
      );
    }

    switch (_orderData!.foodOrderStatus) {
      case FoodOrderStatus.pending:
      case FoodOrderStatus.preparing:
      case FoodOrderStatus.ready:
        return ActiveOrderView(
          order: _orderData!,
          scrollController: _scrollController,
          navigateToMapScreen: _navigateToMapScreen,
        );

      case FoodOrderStatus.completed:
        return CompletedOrderScreen(
          order: _orderData!,
          onBackToHome: () => context.pop(),
          onRateRestaurant: _showRateRestaurantDialog,
        );

      case FoodOrderStatus.rejected:
        return RejectedOrderScreen(
          order: _orderData!,
          onBackToHome: () => context.pop(),
          onContactSupport: _showContactSupportDialog,
        );
    }
  }
}
