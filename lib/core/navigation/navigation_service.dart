import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the NavigationService
final navigationServiceProvider = Provider<NavigationService>((ref) {
  return NavigationService();
});

/// A service that handles app navigation without requiring a BuildContext
class NavigationService {
  /// Global navigation key
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Navigate to a named route
  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
  }

  /// Navigate to a named route and remove all previous routes
  Future<dynamic> navigateToReplacement(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed(routeName, arguments: arguments);
  }

  /// Navigate to a new route
  Future<dynamic> navigateToRoute(Route route) {
    return navigatorKey.currentState!.push(route);
  }

  /// Navigate to order details screen
  Future<dynamic> navigateToOrderDetails(String orderId) {
    // Adjust the route name to match your app's route for order details
    return navigateTo('/restaurant/orders/$orderId', arguments: orderId);
  }

  /// Go back to previous screen
  void goBack() {
    return navigatorKey.currentState!.pop();
  }
}
