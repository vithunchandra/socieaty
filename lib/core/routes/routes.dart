import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/features/account/customer/view/account_view.dart';
import 'package:socieaty/features/authentication/view/landing_page.dart';
import 'package:socieaty/features/authentication/view/signin_page.dart';
import 'package:socieaty/features/authentication/view/signup_customer_page.dart';
import 'package:socieaty/features/authentication/view/signup_page.dart';
import 'package:socieaty/features/authentication/view/signup_restaurant_final_page.dart';
import 'package:socieaty/features/authentication/view/signup_restaurant_first_page.dart';
import 'package:socieaty/features/authentication/view/splash_screen.dart';
import 'package:socieaty/features/authentication/viewstate/signup_restaurant_form_state.dart';
import 'package:socieaty/features/camera/view/camera_screen.dart';
import 'package:socieaty/features/camera/view/image_confirmation_screen.dart';
import 'package:socieaty/features/home/customer/view/home_screen.dart';
import 'package:socieaty/features/livestream/view/livestream_view.dart';
import 'package:socieaty/features/map/view/select_location.dart';
import 'package:socieaty/features/post/post/view/create_post_screen.dart';
import 'package:socieaty/features/search/view/search_view.dart';
import 'package:socieaty/features/shop/customer/view/shop_view.dart';
import 'package:socieaty/shared/widgets/scaffold_with_navbar.dart';

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
        path: '/create_post',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: CreatePostScreen(),
        ),
      ),
      GoRoute(
        path: '/livestream',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LivestreamView(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          debugPrint(state.fullPath);
          final showNavbar = state.fullPath != '/customer/create_post';
          return ScaffoldWithNavbar(
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
                path: '/customer/search',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: SearchView(),
                ),
                routes: [
                  GoRoute(
                    parentNavigatorKey: rootNavigatorKey,
                    path: 'result',
                    pageBuilder: (context, state) => const NoTransitionPage(
                      child: LivestreamView(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/customer/create_post',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: CreatePostScreen(),
                ),
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
    ],
  );
}
