import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/features/account/customer/view/account_view.dart';
import 'package:socieaty/features/account/restaurant/view/restaurant_account_screen.dart';
import 'package:socieaty/features/authentication/view/landing_page.dart';
import 'package:socieaty/features/authentication/view/signin_page.dart';
import 'package:socieaty/features/authentication/view/signup_customer_page.dart';
import 'package:socieaty/features/authentication/view/signup_page.dart';
import 'package:socieaty/features/authentication/view/signup_restaurant_final_page.dart';
import 'package:socieaty/features/authentication/view/signup_restaurant_first_page.dart';
import 'package:socieaty/features/authentication/view/splash_screen.dart';
import 'package:socieaty/features/authentication/viewstate/signup_restaurant_form_state.dart';
import 'package:socieaty/features/home/customer/view/home_screen.dart';
import 'package:socieaty/features/home/restaurant/view/restaurant_dashboard_screen.dart';
import 'package:socieaty/features/livestream/view/live_screen.dart';
import 'package:socieaty/features/livestream/view/livestream_home_screen.dart';
import 'package:socieaty/features/map/view/select_location.dart';
import 'package:socieaty/features/restaurant/view/outlet_screen.dart';
import 'package:socieaty/features/restaurant/view/restaurant_scaffold_with_navbar.dart';
import 'package:socieaty/features/shop/customer/view/shop_view.dart';
import 'package:socieaty/features/transaction/restaurant/view/restaurant_transaction_screen.dart';
import 'package:socieaty/shared/widgets/create_screen.dart';
import 'package:socieaty/features/customer/view/customer_scaffold_with_navbar.dart';

part 'routes.g.dart';

@riverpod
GoRouter router(Ref ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    initialLocation: '/',
    navigatorKey: rootNavigatorKey,
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
      GoRoute(
          path: '/create_content',
          pageBuilder: (context, state) => const NoTransitionPage(
                child: CreateScreen(),
              ),
          routes: [
            GoRoute(
              parentNavigatorKey: rootNavigatorKey,
              path: 'live',
              builder: (context, state) {
                return LiveScreen(
                  args: state.extra as LiveScreenArgs,
                );
              },
            ),
          ]),
      GoRoute(
        path: '/livestream',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LivestreamHomeScreen(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          debugPrint(state.fullPath);
          final showNavbar = state.fullPath != '/customer/create_post';
          return CustomerScaffoldWithNavbar(
            navigationShell: navigationShell,
            showNavbar: showNavbar,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/customer/home',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomeScreen(),
                ),
              )
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/customer/livestream',
                pageBuilder: (context, state) => const NoTransitionPage(child: Scaffold()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/customer/create_post',
                pageBuilder: (context, state) => const NoTransitionPage(child: Scaffold()),
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
                path: '/customer/profile',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: AccountView(),
                ),
              ),
            ],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return RestaurantScaffoldWithNavbar(
            navigationShell: navigationShell,
            showNavbar: true,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                  path: '/restaurant/dashboard',
                  pageBuilder: (context, state) => const NoTransitionPage(
                        child: RestaurantDashboardScreen(),
                      ),
                  routes: [
                    GoRoute(
                      path: '/outlet',
                      parentNavigatorKey: rootNavigatorKey,
                      builder: (context, state) => const OutletScreen(),
                    )
                  ])
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/restaurant/transaksi',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: RestaurantTransactionScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/restaurant/profile',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: RestaurantAccountScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
