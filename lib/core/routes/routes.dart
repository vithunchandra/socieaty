import 'package:go_router/go_router.dart';
import 'package:socieaty/features/authentication/model/signup_restaurant_form_state.dart';
import 'package:socieaty/features/authentication/view/landing_page.dart';
import 'package:socieaty/features/authentication/view/signin_page.dart';
import 'package:socieaty/features/authentication/view/signup_customer_page.dart';
import 'package:socieaty/features/authentication/view/signup_page.dart';
import 'package:socieaty/features/authentication/view/signup_restaurant_final_page.dart';
import 'package:socieaty/features/authentication/view/signup_restaurant_first_page.dart';
import 'package:socieaty/features/map/view/select_location.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LandingPage()),
    GoRoute(path: '/signin', builder: (context, state) => SignInPage()),
    GoRoute(path: '/signup', builder: (context, state) => const SignUpPage(), routes: [
      GoRoute(path: 'customer', builder: (context, state) => SignupCustomerPage()),
      GoRoute(path: 'restaurant/first', builder: (context, state) => SignupRestaurantFirstPage()),
      GoRoute(
          path: 'restaurant/final',
          builder: (context, state) {
            SignupRestaurantFormState data = state.extra as SignupRestaurantFormState;
            return SignupRestaurantFinalPage(data);
          }),
    ]),
    GoRoute(path: '/select_location', builder: (context, state) => const SelectLocation()),
  ],
);
