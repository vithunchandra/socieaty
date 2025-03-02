import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socieaty/core/enums/bank.enum.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/core/enums/user_role.enum.dart';
import 'package:socieaty/features/customer/model/customer_data.dart';
import 'package:socieaty/features/customer/model/socieaty_customer.dart';
import 'package:socieaty/features/food_menu/model/food_menu.dart';
import 'package:socieaty/features/food_menu/model/menu_category.dart';
import 'package:socieaty/features/restaurant/model/restaurant_data.dart';
import 'package:socieaty/features/restaurant/model/restaurant_theme.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';
import 'package:socieaty/features/transaction/model/food_order_transaction.dart';
import 'package:socieaty/features/transaction/model/transaction_menu_item.dart';

class RestaurantTransactionScreen extends StatefulWidget {
  final String? orderId;

  const RestaurantTransactionScreen({super.key, this.orderId});

  @override
  State<RestaurantTransactionScreen> createState() => _RestaurantTransactionScreenState();
}

class _RestaurantTransactionScreenState extends State<RestaurantTransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  // For demonstration purposes, creating dummy data
  final List<FoodOrderTransaction> _dummyOrders = [
    FoodOrderTransaction(
      id: 'order-123456789',
      serviceType: TransactionServiceType.foodOrder,
      grossAmount: 8500000,
      serviceFee: 200000,
      status: TransactionStatus.pending,
      restaurant: SocieatyRestaurant(
        id: 'rest-123',
        name: 'Delicious Restaurant',
        email: 'restaurant@example.com',
        phoneNumber: '+6281234567890',
        role: UserRole.restaurant,
        restaurantData: RestaurantData(
          id: 'restdata-123',
          restaurantBannerUrl: 'http://192.168.200.205:3000/files/menu/dummy/menu_7.jpg',
          location: const LatLng(-6.2088, 106.8456),
          themes: const [RestaurantTheme(id: 1, name: 'Casual Dining')],
          payoutBank: BankEnum.bca,
          accountNumber: '1234567890',
          openTime: '09:00',
          closeTime: '22:00',
        ),
      ),
      customer: SocieatyCustomer(
        id: 'cust-123',
        name: 'John Smith',
        email: 'john@example.com',
        phoneNumber: '+6287654321098',
        role: UserRole.customer,
        customerData: const CustomerData(
          id: 'custdata-123',
          wallet: 1000000,
        ),
      ),
      note:
          'Please make the nasi goreng extra spicy and don\'t include onions. Add extra egg if possible.',
      menuItems: [
        TransactionMenuItem(
          id: 'item-1',
          menu: FoodMenu(
            id: 'menu-1',
            restaurantId: 'rest-123',
            name: 'Nasi Goreng Special',
            description: 'Delicious fried rice with egg and chicken',
            price: 3500000,
            pictureUrl: 'http://192.168.200.205:3000/files/menu/dummy/menu_1.jpg',
            estimatedTime: 15,
            isStockAvailable: true,
            categories: const [MenuCategory(id: 1, name: 'Main Course')],
          ),
          quantity: 2,
          price: 3500000,
          totalPrice: 7000000,
        ),
        TransactionMenuItem(
          id: 'item-2',
          menu: FoodMenu(
            id: 'menu-2',
            restaurantId: 'rest-123',
            name: 'Iced Tea',
            description: 'Refreshing iced tea',
            price: 1500000,
            pictureUrl: 'http://192.168.200.205:3000/files/menu/dummy/menu_2.jpg',
            estimatedTime: 5,
            isStockAvailable: true,
            categories: const [MenuCategory(id: 2, name: 'Beverages')],
          ),
          quantity: 1,
          price: 1500000,
          totalPrice: 1500000,
        ),
      ],
    ),
    FoodOrderTransaction(
      id: 'order-987654321',
      serviceType: TransactionServiceType.foodOrder,
      grossAmount: 5000000,
      serviceFee: 150000,
      status: TransactionStatus.completed,
      restaurant: SocieatyRestaurant(
        id: 'rest-123',
        name: 'Delicious Restaurant',
        email: 'restaurant@example.com',
        phoneNumber: '+6281234567890',
        role: UserRole.restaurant,
        restaurantData: RestaurantData(
          id: 'restdata-123',
          restaurantBannerUrl: 'http://192.168.200.205:3000/files/menu/dummy/menu_7.jpg',
          location: const LatLng(-6.2088, 106.8456),
          themes: const [RestaurantTheme(id: 1, name: 'Casual Dining')],
          payoutBank: BankEnum.bca,
          accountNumber: '1234567890',
          openTime: '09:00',
          closeTime: '22:00',
        ),
      ),
      customer: SocieatyCustomer(
        id: 'cust-456',
        name: 'Sarah Johnson',
        email: 'sarah@example.com',
        phoneNumber: '+6285555555555',
        role: UserRole.customer,
        customerData: const CustomerData(
          id: 'custdata-456',
          wallet: 2000000,
        ),
      ),
      note: 'No pickles in the burger, please. Add extra cheese.',
      menuItems: [
        TransactionMenuItem(
          id: 'item-3',
          menu: FoodMenu(
            id: 'menu-3',
            restaurantId: 'rest-123',
            name: 'Beef Burger',
            description: 'Juicy beef burger with cheese',
            price: 5000000,
            pictureUrl: 'http://192.168.200.205:3000/files/menu/dummy/menu_3.jpg',
            estimatedTime: 20,
            isStockAvailable: true,
            categories: const [MenuCategory(id: 1, name: 'Main Course')],
          ),
          quantity: 1,
          price: 5000000,
          totalPrice: 5000000,
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });

    // If we received an orderId from notification, highlight that order
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.orderId != null) {
        _showOrderDetails(widget.orderId!);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showOrderDetails(String orderId) {
    // Find the order in our dummy data that matches the orderId
    final order = _dummyOrders.firstWhere(
      (order) => order.id == orderId,
      orElse: () => _dummyOrders.first, // Fallback to first order if not found
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollController) => _buildOrderDetailsSheet(order, scrollController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Transaksi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Baru'),
            Tab(text: 'Berlangsung'),
            Tab(text: 'Selesai'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList(status: [TransactionStatus.pending]),
          _buildOrderList(status: [TransactionStatus.confirming, TransactionStatus.process]),
          _buildOrderList(status: [TransactionStatus.completed]),
        ],
      ),
    );
  }

  Widget _buildOrderList({required List<TransactionStatus> status}) {
    final filteredOrders = _dummyOrders.where((order) => status.contains(order.status)).toList();

    if (filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyStateIcon(status.first),
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyStateTitle(status.first),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              _getEmptyStateMessage(status.first),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredOrders.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(FoodOrderTransaction order) {
    final formatter = NumberFormat("#,###", "en_US");
    final statusColors = {
      TransactionStatus.confirming: Colors.blue,
      TransactionStatus.pending: Colors.orange,
      TransactionStatus.process: Colors.amber,
      TransactionStatus.completed: Colors.green,
      TransactionStatus.cancelled: Colors.red,
    };

    final statusNames = {
      TransactionStatus.confirming: 'KONFIRMASI',
      TransactionStatus.pending: 'MENUNGGU',
      TransactionStatus.process: 'DIPROSES',
      TransactionStatus.completed: 'SELESAI',
      TransactionStatus.cancelled: 'DIBATALKAN',
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showOrderDetails(order.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: statusColors[order.status]!.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pesanan #${order.id.substring(order.id.length - 8)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColors[order.status],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusNames[order.status] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Order content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer row
                  Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        radius: 20,
                        child: Text(
                          order.customer.name[0],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Customer details - removed phone number
                      Expanded(
                        child: Text(
                          order.customer.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 24),

                  // Order summary
                  if (order.menuItems.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Food image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            order.menuItems.first.menu.pictureUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Order info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${order.menuItems.first.quantity}× ${order.menuItems.first.menu.name}',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              if (order.menuItems.length > 1)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    '+ ${order.menuItems.length - 1} ${order.menuItems.length > 2 ? "item lainnya" : "item lainnya"}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${order.menuItems.length} total item',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                  ),
                                  Text(
                                    'Rp ${formatter.format((order.grossAmount + order.serviceFee) / 100)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Action buttons for pending orders
                  if (order.status == TransactionStatus.pending)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                // Show order details
                                _showOrderDetails(order.id);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Theme.of(context).primaryColor,
                                side: BorderSide(color: Theme.of(context).primaryColor),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              child: const Text('Lihat Detail'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                                // Accept order
                                _showOrderDetails(order.id);
                              },
                              child: const Text('Terima'),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getEmptyStateIcon(TransactionStatus status) {
    if (status == TransactionStatus.completed) {
      return Icons.task_alt;
    } else if (status == TransactionStatus.cancelled) {
      return Icons.cancel;
    } else {
      return Icons.receipt_long;
    }
  }

  String _getEmptyStateTitle(TransactionStatus status) {
    if (status == TransactionStatus.completed) {
      return 'Tidak Ada Pesanan Selesai';
    } else if (status == TransactionStatus.process || status == TransactionStatus.confirming) {
      return 'Tidak Ada Pesanan Berlangsung';
    } else {
      return 'Tidak Ada Pesanan Baru';
    }
  }

  String _getEmptyStateMessage(TransactionStatus status) {
    if (status == TransactionStatus.completed) {
      return 'Pesanan yang telah selesai akan muncul di sini';
    } else if (status == TransactionStatus.process || status == TransactionStatus.confirming) {
      return 'Pesanan yang sedang diproses akan muncul di sini';
    } else {
      return 'Pesanan baru yang menunggu konfirmasi akan muncul di sini';
    }
  }

  Widget _buildOrderDetailsSheet(FoodOrderTransaction order, ScrollController scrollController) {
    final formatter = NumberFormat("#,###", "en_US");
    final statusColors = {
      TransactionStatus.confirming: Colors.blue,
      TransactionStatus.pending: Colors.orange,
      TransactionStatus.process: Colors.amber,
      TransactionStatus.completed: Colors.green,
      TransactionStatus.cancelled: Colors.red,
    };

    final statusNames = {
      TransactionStatus.confirming: 'KONFIRMASI',
      TransactionStatus.pending: 'MENUNGGU',
      TransactionStatus.process: 'DIPROSES',
      TransactionStatus.completed: 'SELESAI',
      TransactionStatus.cancelled: 'DIBATALKAN',
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Draggable handle
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Main content area with scroll view
          Expanded(
            child: ListView(
              controller: scrollController,
              children: [
                // Order header section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pesanan #${order.id.substring(order.id.length - 8)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColors[order.status]?.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusNames[order.status] ?? '',
                        style: TextStyle(
                          color: statusColors[order.status],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Customer info section
                const Text(
                  'Informasi Pelanggan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundImage: order.customer.profilePictureUrl != null
                        ? NetworkImage(order.customer.profilePictureUrl!)
                        : null,
                    radius: 20,
                    child: order.customer.profilePictureUrl == null
                        ? Text(order.customer.name[0])
                        : null,
                  ),
                  title: Text(
                    order.customer.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),

                const Divider(height: 32),

                // Additional Note section (if present)
                if (order.note.isNotEmpty) ...[
                  const Text(
                    'Catatan Tambahan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.note_alt, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            order.note,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 32),
                ],

                // Order items section
                const Text(
                  'Item Pesanan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ...order.menuItems.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Food image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.menu.pictureUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Food details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.menu.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rp ${formatter.format(item.price / 100)} x ${item.quantity}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Price
                          Text(
                            'Rp ${formatter.format(item.totalPrice / 100)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )),

                const Divider(height: 32),

                // Payment details section
                const Text(
                  'Detail Pembayaran',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal'),
                    Text('Rp ${formatter.format(order.grossAmount / 100)}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Biaya Layanan'),
                    Text('Rp ${formatter.format(order.serviceFee / 100)}'),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Rp ${formatter.format((order.grossAmount + order.serviceFee) / 100)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Action buttons at the bottom (fixed position)
          if (order.status == TransactionStatus.pending)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Implement reject order functionality
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Tolak Pesanan'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        // Implement accept order functionality
                        Navigator.pop(context);
                      },
                      child: const Text('Terima Pesanan'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
