import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/features/customer/socket/customer_socket_service.dart';
import 'package:socieaty/features/transaction/model/food_order_transaction.dart';
import 'package:socieaty/features/transaction/repository/transaction_repository.dart';
import 'package:socieaty/shared/widgets/dotted_divider.dart';
import 'dart:async';

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

  // For controlling the scroll and map collapse behavior
  final ScrollController _scrollController = ScrollController();
  bool _isMapCollapsed = false;
  double _maxMapHeight = 300.0; // Expanded map height
  final double _minMapHeight = kToolbarHeight; // Standard app bar height

  // Google Maps controller
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();

  // Dummy location data
  static const LatLng _userLocation = LatLng(-6.2088, 106.8456); // Jakarta area
  static const LatLng _restaurantLocation =
      LatLng(-6.2008, 106.8319); // Different location in Jakarta

  // Markers set
  final Set<Marker> _markers = {};

  // Polyline for route
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    // Initialize socket service
    _socketService = ref.read(customerSocketServiceProvider);

    // Setup scroll listener to track collapsing state
    _scrollController.addListener(_handleScroll);

    // Setup socket listeners after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupSocketListeners();
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _removeSocketListeners();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final double offset = _scrollController.offset;
    final threshold = _maxMapHeight * 0.5;
    final isCollapsed = offset > threshold;

    if (isCollapsed != _isMapCollapsed) {
      setState(() {
        _isMapCollapsed = isCollapsed;
      });
    }
  }

  void _loadInitialData() async {
    try {
      final repository = ref.read(transactionRepositoryProvider);
      final result = await repository.getFoodOrderTransaction(widget.orderId);

      switch (result) {
        case Success(data: final data):
          if (mounted) {
            setState(() {
              _orderData = data;
              _isLoading = false;
            });
            // Setup map data once order data is loaded
            _setupMapData();
          }
        case Error(error: final error):
          if (mounted) {
            setState(() {
              _errorMessage = error.toString();
              _isLoading = false;
            });
          }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
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

  void _setupMapData() {
    // Initialize markers
    _markers.add(
      Marker(
        markerId: const MarkerId('user_location'),
        position: _userLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Your Location'),
      ),
    );

    _markers.add(
      Marker(
        markerId: const MarkerId('restaurant_location'),
        position: _restaurantLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Restaurant Location'),
      ),
    );

    // Create a simple polyline for the route
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: [_userLocation, _restaurantLocation],
        color: AppPallete.primaryColor,
        width: 5,
      ),
    );
  }

  String _getStatusMessage(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.confirming:
        return 'Restaurant is confirming your order';
      case TransactionStatus.pending:
        return 'Order is being processed';
      case TransactionStatus.process:
        return 'Your food is being prepared';
      case TransactionStatus.completed:
        return 'Order has been completed';
      case TransactionStatus.cancelled:
        return 'Order was cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    _maxMapHeight = MediaQuery.of(context).size.height * 0.5;
    return Scaffold(
      backgroundColor: AppPallete.neutralColor.shade50,
      body: _isLoading
          ? _buildLoadingView()
          : _errorMessage != null && _orderData == null
              ? _buildErrorView()
              : _buildTrackingView(_orderData!),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading order details...'),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error loading order: $_errorMessage'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadInitialData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingView(FoodOrderTransaction order) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Collapsible Map in AppBar
        SliverAppBar(
          pinned: true,
          expandedHeight: _maxMapHeight,
          collapsedHeight: _minMapHeight,
          backgroundColor: _isMapCollapsed ? Colors.white : Colors.transparent,
          elevation: _isMapCollapsed ? 4 : 0,
          shadowColor: Colors.black26,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: _isMapCollapsed ? Colors.black : Colors.white,
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Track Order #${widget.orderId}',
            style: TextStyle(
              color: _isMapCollapsed ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            background: _buildMapPlaceholder(order),
          ),
        ),
        // Content with padding
        SliverList(
          delegate: SliverChildListDelegate([
            // Status section
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
              child: _buildStatusSection(order),
            ),

            // Transaction Information
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 0),
              child: _buildTransactionInfoSection(order),
            ),

            const SizedBox(
              height: kToolbarHeight - 10,
            )
          ]),
        ),
      ],
    );
  }

  Widget _buildMapPlaceholder(FoodOrderTransaction order) {
    // Flag for development - set to true to show Google Map with API key
    // Set to false to show a placeholder in development
    const bool useGoogleMap = true;

    return Stack(
      children: [
        if (useGoogleMap)
          // Google Map implementation
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _restaurantLocation,
              zoom: 15,
            ),
            markers: _markers,
            polylines: _polylines,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            compassEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _mapController.complete(controller);
            },
          ),

        Positioned(
          bottom: 40,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.restaurant, color: AppPallete.primaryColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  order.restaurant.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),

        // User location indicator
        Positioned(
          bottom: 90,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.my_location, color: Colors.blue, size: 16),
                const SizedBox(width: 4),
                const Text(
                  'Your Location',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Add development note if not using actual Google Maps
        if (!useGoogleMap) _buildMapNoteOverlay(),

        // ETA and Map Controls overlay
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.directions_car, color: AppPallete.primaryColor),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '15-20 min',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppPallete.primaryColor,
                        ),
                      ),
                      const Text(
                        '3.2 km away',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Map controls - only show if using actual Google Maps
        if (useGoogleMap)
          Positioned(
            right: 16,
            bottom: 140,
            child: Column(
              children: [
                // Zoom in button
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      final controller = await _mapController.future;
                      controller.animateCamera(CameraUpdate.zoomIn());
                    },
                  ),
                ),

                // Zoom out button
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () async {
                      final controller = await _mapController.future;
                      controller.animateCamera(CameraUpdate.zoomOut());
                    },
                  ),
                ),

                // Center on route button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.gps_fixed),
                    onPressed: () async {
                      final controller = await _mapController.future;

                      // Calculate ideal zoom to include both points
                      controller.animateCamera(
                        CameraUpdate.newLatLngBounds(
                          LatLngBounds(
                            southwest: LatLng(
                              _userLocation.latitude < _restaurantLocation.latitude
                                  ? _userLocation.latitude
                                  : _restaurantLocation.latitude,
                              _userLocation.longitude < _restaurantLocation.longitude
                                  ? _userLocation.longitude
                                  : _restaurantLocation.longitude,
                            ),
                            northeast: LatLng(
                              _userLocation.latitude > _restaurantLocation.latitude
                                  ? _userLocation.latitude
                                  : _restaurantLocation.latitude,
                              _userLocation.longitude > _restaurantLocation.longitude
                                  ? _userLocation.longitude
                                  : _restaurantLocation.longitude,
                            ),
                          ),
                          100, // padding
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStatusSection(FoodOrderTransaction order) {
    // Determine status colors based on current status
    final Color statusColor = _getStatusColor(order.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppPallete.neutralColor.shade200,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Status header - centered status text with background
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStatusIcon(order.status),
                    color: statusColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getStatusMessage(order.status),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Restaurant info row
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                  order.restaurant.restaurantData.restaurantBannerUrl,
                ),
                radius: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.restaurant.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: AppPallete.primaryColor, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "Restaurant Location",
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppPallete.neutralColor.shade600,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppPallete.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.phone, size: 16, color: AppPallete.primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      'Call',
                      style: TextStyle(
                        color: AppPallete.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Status timeline - call the updated implementation
          _buildHorizontalStatusTimeline(context, order.status),

          const SizedBox(height: 24),

          // ETA information
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppPallete.neutralColor.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppPallete.neutralColor.shade300, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.access_time, color: AppPallete.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Estimated time: 15-20 minutes',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.confirming:
        return Colors.orange;
      case TransactionStatus.pending:
        return Colors.blue;
      case TransactionStatus.process:
        return AppPallete.primaryColor;
      case TransactionStatus.completed:
        return Colors.green;
      case TransactionStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.confirming:
        return Icons.schedule;
      case TransactionStatus.pending:
        return Icons.pending_actions;
      case TransactionStatus.process:
        return Icons.restaurant;
      case TransactionStatus.completed:
        return Icons.check_circle;
      case TransactionStatus.cancelled:
        return Icons.cancel;
    }
  }

  Widget _buildTransactionInfoSection(FoodOrderTransaction order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppPallete.neutralColor.shade200,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: AppPallete.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Order Summary',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const DottedDivider(color: AppPallete.neutralColor),
          const SizedBox(height: 12),

          // Compact order items grid
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              order.menuItems.length,
              (index) {
                final item = order.menuItems[index];
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Quantity
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppPallete.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            item.quantity.toString(),
                            style: TextStyle(
                              color: AppPallete.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Item name
                      Expanded(
                        child: Text(
                          item.menu.name,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Price
                      Text(
                        item.totalPrice.toIDRFormat(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: DottedDivider(color: AppPallete.neutralColor),
          ),

          // Payment Details with improved styling
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                order.grossAmount.toIDRFormat(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Service Fee',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                order.serviceFee.toIDRFormat(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Container(
              height: 1,
              color: AppPallete.neutralColor.shade300,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Payment',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                (order.grossAmount + order.serviceFee).toIDRFormat(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppPallete.primaryColor,
                    ),
              ),
            ],
          ),

          // Additional Notes (if any)
          if (order.note.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Additional Notes',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppPallete.neutralColor.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppPallete.neutralColor.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.sticky_note_2_outlined,
                    color: AppPallete.primaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.note,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Simplified horizontal timeline design
  Widget _buildHorizontalStatusTimeline(BuildContext context, TransactionStatus status) {
    bool isProcessing = status == TransactionStatus.process;
    bool isCompleted = status == TransactionStatus.completed;
    bool isCancelled = status == TransactionStatus.cancelled;
    bool isPending = status == TransactionStatus.pending;
    bool isConfirming = status == TransactionStatus.confirming;

    const double circleSize = 40.0;
    const double lineThickness = 3.0;

    if (isCancelled) {
      return _buildCancelledStatus();
    }

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Confirming
            Column(
              children: [
                Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPending || isProcessing || isCompleted
                        ? AppPallete.primaryColor
                        : isConfirming
                            ? AppPallete.primaryColor.withOpacity(0.2)
                            : AppPallete.neutralColor.shade200,
                    border: Border.all(
                      color: isPending || isProcessing || isCompleted || isConfirming
                          ? AppPallete.primaryColor
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isPending || isProcessing || isCompleted ? Icons.check : Icons.receipt_long,
                    color: isPending || isProcessing || isCompleted
                        ? Colors.white
                        : isConfirming
                            ? AppPallete.primaryColor
                            : AppPallete.neutralColor.shade500,
                    size: circleSize * 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Confirmed',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isPending || isProcessing || isCompleted || isConfirming
                        ? AppPallete.primaryColor
                        : AppPallete.neutralColor.shade500,
                  ),
                ),
              ],
            ),

            // Line 1
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                width: 40,
                height: lineThickness,
                color: isPending || isProcessing || isCompleted
                    ? AppPallete.primaryColor
                    : AppPallete.neutralColor.shade300,
              ),
            ),

            // Processing
            Column(
              children: [
                Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? AppPallete.primaryColor
                        : isProcessing
                            ? AppPallete.primaryColor.withOpacity(0.2)
                            : AppPallete.neutralColor.shade200,
                    border: Border.all(
                      color: isProcessing || isCompleted
                          ? AppPallete.primaryColor
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check : Icons.restaurant,
                    color: isCompleted
                        ? Colors.white
                        : isProcessing
                            ? AppPallete.primaryColor
                            : AppPallete.neutralColor.shade500,
                    size: circleSize * 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Preparing',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isProcessing || isCompleted
                        ? AppPallete.primaryColor
                        : AppPallete.neutralColor.shade500,
                  ),
                ),
              ],
            ),

            // Line 2
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                width: 40,
                height: lineThickness,
                color: isCompleted ? AppPallete.primaryColor : AppPallete.neutralColor.shade300,
              ),
            ),

            // Completed
            Column(
              children: [
                Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? AppPallete.primaryColor : AppPallete.neutralColor.shade200,
                    border: Border.all(
                      color: isCompleted ? AppPallete.primaryColor : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: isCompleted ? Colors.white : AppPallete.neutralColor.shade500,
                    size: circleSize * 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Completed',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isCompleted ? AppPallete.primaryColor : AppPallete.neutralColor.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelledStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cancel,
                  color: Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Order Cancelled',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Note about Google Maps API for development
  Widget _buildMapNoteOverlay() {
    return Positioned(
      top: 70,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber.shade700),
        ),
        child: Column(
          children: [
            const Text(
              'Development Note',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'To display Google Maps, please add a valid API key in AndroidManifest.xml and Info.plist',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              'For development, this placeholder map is being shown.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
