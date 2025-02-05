import 'package:flutter/material.dart';

class RestaurantTransactionScreen extends StatelessWidget {
  const RestaurantTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Text("Transaction"),
        ),
      ),
    );
  }
}