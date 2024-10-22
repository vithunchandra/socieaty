import 'package:go_router/go_router.dart';
import 'package:socieaty/features/authentication/view/landing_page.dart';
import 'package:socieaty/features/authentication/view/signin_page.dart';
import 'package:socieaty/features/authentication/view/signup_customer_page.dart';
import 'package:socieaty/features/authentication/view/signup_page.dart';
import 'package:socieaty/features/authentication/view/signup_restaurant_page.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LandingPage()),
    GoRoute(path: '/signin', builder: (context, state) => SignInPage()),
    GoRoute(path: '/signup', builder: (context, state) => const SignUpPage(), routes: [
      GoRoute(path: 'customer', builder: (context, state) => SignupCustomerPage()),
      GoRoute(path: 'restaurant', builder: (context, state) => const SignupRestaurantPage()),
    ]),
  ],
);
