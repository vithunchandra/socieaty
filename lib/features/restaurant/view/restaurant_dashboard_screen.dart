import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/features/restaurant/socket/restaurant_socket_service.dart';

/// Main dashboard screen for restaurant users.
///
/// This screen includes the order notification listener to show new order notifications.
/// The socket connection is initialized when this screen loads and is disconnected when the user logs out.
class RestaurantDashboardScreen extends ConsumerStatefulWidget {
  const RestaurantDashboardScreen({super.key});

  @override
  ConsumerState<RestaurantDashboardScreen> createState() => _RestaurantDashboardScreenState();
}

class _RestaurantDashboardScreenState extends ConsumerState<RestaurantDashboardScreen> {
  @override
  void initState() {
    super.initState();

    // Initialize socket connection when the dashboard loads
    _initializeSocketConnection();
  }

  @override
  void dispose() {
    // Disconnect socket when leaving the dashboard (e.g., on logout)
    _disconnectSocket();
    super.dispose();
  }

  void _initializeSocketConnection() {
    // Initialize the socket connection for receiving restaurant notifications
    ref.read(restaurantSocketServiceProvider).initConnection();
  }

  void _disconnectSocket() {
    // Disconnect the socket when logging out
    ref.read(restaurantSocketServiceProvider).disconnect();
  }

  void _handleLogout() {
    // Disconnect socket before navigating away
    _disconnectSocket();

    // Navigate to login screen (implement your navigation logic here)
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the entire dashboard with the notification listener
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard content
              const Text(
                'Welcome to Your Restaurant Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Quick stats
              _buildStatsCard(),
              const SizedBox(height: 24),

              // Recent orders list
              const Text(
                'Recent Orders',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Placeholder for a list of recent orders
              Expanded(
                child: ListView.builder(
                  itemCount: 5, // Placeholder count
                  itemBuilder: (context, index) => _buildOrderItem(index),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            _StatItem(
              value: '12',
              label: 'New Orders',
              icon: Icons.receipt_long,
              color: Colors.blue,
            ),
            _StatItem(
              value: '4',
              label: 'In Progress',
              icon: Icons.hourglass_top,
              color: Colors.orange,
            ),
            _StatItem(
              value: '32',
              label: 'Completed',
              icon: Icons.done_all,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(int index) {
    // Placeholder order item
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: const Icon(Icons.receipt, color: Colors.blue),
        ),
        title: Text('Order #10${index + 1}'),
        subtitle: Text('Table ${index + 1} • ${index + 2} items • \$${20 + index * 5}'),
        trailing: _getOrderStatusChip(index % 3),
        onTap: () {
          // Handle order tap
        },
      ),
    );
  }

  Widget _getOrderStatusChip(int statusIndex) {
    switch (statusIndex) {
      case 0:
        return const Chip(
          label: Text('New'),
          backgroundColor: Colors.blue,
          labelStyle: TextStyle(color: Colors.white),
        );
      case 1:
        return const Chip(
          label: Text('Preparing'),
          backgroundColor: Colors.orange,
          labelStyle: TextStyle(color: Colors.white),
        );
      case 2:
        return const Chip(
          label: Text('Ready'),
          backgroundColor: Colors.green,
          labelStyle: TextStyle(color: Colors.white),
        );
      default:
        return const Chip(
          label: Text('Unknown'),
          backgroundColor: Colors.grey,
          labelStyle: TextStyle(color: Colors.white),
        );
    }
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatItem({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
