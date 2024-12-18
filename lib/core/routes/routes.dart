import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/features/authentication/view/landing_page.dart';
import 'package:socieaty/features/authentication/view/signin_page.dart';
import 'package:socieaty/features/authentication/view/signup_customer_page.dart';
import 'package:socieaty/features/authentication/view/signup_page.dart';
import 'package:socieaty/features/authentication/view/signup_restaurant_final_page.dart';
import 'package:socieaty/features/authentication/view/signup_restaurant_first_page.dart';
import 'package:socieaty/features/authentication/view/splash_screen.dart';
import 'package:socieaty/features/authentication/viewstate/signup_restaurant_form_state.dart';
import 'package:socieaty/features/customer/view/customer_profile.dart';
import 'package:socieaty/features/customer_features/account/view/account_view.dart';
import 'package:socieaty/features/customer_features/home/view/home_view.dart';
import 'package:socieaty/features/customer_features/livestream/view/livestream_view.dart';
import 'package:socieaty/features/customer_features/post/view/post_view.dart';
import 'package:socieaty/features/customer_features/shop/view/shop_view.dart';
import 'package:socieaty/features/map/view/select_location.dart';
import 'package:socieaty/shared/widgets/scaffold_with_navbar.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  initialLocation: '/',
  navigatorKey: _rootNavigatorKey,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/landing', builder: (context, state) => const LandingPage()),
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
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavbar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/customer/home',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: HomeView(),
              ),
              routes: [
                GoRoute(
                  path: '/customer/livestream',
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: LivestreamView(),
                  ),
                ),
                GoRoute(
                  path: '/customer/post',
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: PostView(),
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/customer/shop',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ShopView(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/customer/account',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: AccountView(),
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(path: '/customer_profile', builder: (context, state) => CustomerProfile()),
  ],
);
