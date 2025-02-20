import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RestaurantTransactionScreen extends StatelessWidget {
  const RestaurantTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FilledButton(
            onPressed: () {
              context.go('/restaurant/transaksi/page_a');
            },
            child: Text('Page A'),
          ),
          FilledButton(
            onPressed: () {
              context.go('/restaurant/transaksi/page_b');
            },
            child: Text('Page B'),
          ),
          FilledButton(
            onPressed: () {
              context.go('/restaurant/transaksi/page_c');
            },
            child: Text('Page C'),
          ),
        ],
      ),
    ));
  }
}
