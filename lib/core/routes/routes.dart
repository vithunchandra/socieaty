import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/features/account/restaurant/view/restaurant_account_screen.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/authentication/view/landing_page.dart';
import 'package:socieaty/features/authentication/view/signin_page.dart';
import 'package:socieaty/features/authentication/view/signup_customer_page.dart';
import 'package:socieaty/features/authentication/view/signup_page.dart';
import 'package:socieaty/features/authentication/view/signup_restaurant_final_page.dart';
import 'package:socieaty/features/authentication/view/signup_restaurant_first_page.dart';
import 'package:socieaty/features/authentication/view/splash_screen.dart';
import 'package:socieaty/features/authentication/viewstate/signup_restaurant_form_state.dart';
import 'package:socieaty/features/customer/model/socieaty_customer.dart';
import 'package:socieaty/features/customer/view/update_customer_profile_screen.dart';
import 'package:socieaty/features/food_menu/customer/view/outlet_food_menu_screen.dart';
import 'package:socieaty/features/food_order_chat/view/chat_screen.dart';
import 'package:socieaty/features/home/customer/view/home_screen.dart';
import 'package:socieaty/features/home/restaurant/view/restaurant_dashboard_screen.dart';
import 'package:socieaty/features/livestream/view/livestream_home_screen.dart';
import 'package:socieaty/features/map/view/select_location.dart';
import 'package:socieaty/features/post/post/view/post_screen.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';
import 'package:socieaty/features/restaurant/view/restaurant_scaffold_with_navbar.dart';
import 'package:socieaty/features/food_menu/restaurant/view/create_food_menu_screen.dart';
import 'package:socieaty/features/food_menu/restaurant/view/owner_food_menu_screen.dart';
import 'package:socieaty/features/food_menu/restaurant/view/update_food_menu_screen.dart';
import 'package:socieaty/features/shop/customer/view/shop_screen.dart';
import 'package:socieaty/features/shop/customer/view/shop_search_screen.dart';
import 'package:socieaty/features/transaction/customer/view/create_transaction_screen.dart';
import 'package:socieaty/features/transaction/model/food_order_transaction.dart';
import 'package:socieaty/features/transaction/restaurant/view/restaurant_transaction_screen.dart';
import 'package:socieaty/features/user/view/profile_loader_screen.dart';
import 'package:socieaty/shared/widgets/create_screen.dart';
import 'package:socieaty/features/customer/view/customer_scaffold_with_navbar.dart';
import 'package:socieaty/features/transaction/customer/view/track_order_screen.dart';
import 'package:socieaty/features/transaction/restaurant/view/restaurant_transaction_history_screen.dart';

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
      ),
      GoRoute(
        path: '/livestreams',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LivestreamHomeScreen(),
        ),
      ),
      GoRoute(
        path: '/posts',
        builder: (context, state) => PostScreen(
          args: state.extra as PostScreenArgs,
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
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
                  child: ShopScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'search',
                    pageBuilder: (context, state) => const NoTransitionPage(
                      child: ShopSearchScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/customer/profile',
                pageBuilder: (context, state) {
                  final userId = ref.watch(authLocalRepositoryProvider).getUserData()?.id ?? '';
                  return NoTransitionPage(
                    child: ProfileLoaderScreen(userId: userId),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'update',
                    pageBuilder: (context, state) => NoTransitionPage(
                      child: UpdateCustomerProfileScreen(user: state.extra as SocieatyCustomer),
                    ),
                  )
                ],
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
                    pageBuilder: (context, state) {
                      final userId = ref.watch(authLocalRepositoryProvider).getUserData()?.id ?? '';
                      return NoTransitionPage(
                        child: ProfileLoaderScreen(userId: userId),
                      );
                    },
                  ),
                  GoRoute(
                    path: "/outlet/menu",
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) =>
                        OwnerFoodMenuScreen(restaurant: state.extra as SocieatyRestaurant),
                    routes: [
                      GoRoute(
                        path: '/create',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) => const CreateFoodMenuScreen(),
                      ),
                      GoRoute(
                        path: '/update',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) => UpdateFoodMenuScreen(
                          args: state.extra as UpdateFoodMenuScreenArgs,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/restaurant/transaksi',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: RestaurantTransactionScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'history',
                    pageBuilder: (context, state) => const NoTransitionPage(
                      child: RestaurantTransactionHistoryScreen(),
                    ),
                  ),
                ],
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
      GoRoute(
        path: '/track-order',
        builder: (context, state) => TrackOrderScreen(
          orderId: state.extra as String,
        ),
      ),
      GoRoute(
        path: '/track-order/message',
        builder: (context, state) => ChatScreen(
          order: state.extra as FoodOrderTransaction,
        ),
      ),
      GoRoute(
        path: '/:userId',
        builder: (context, state) =>
            ProfileLoaderScreen(userId: state.pathParameters['userId'] ?? ''),
        routes: [
          GoRoute(
            path: 'shop',
            builder: (context, state) => OutletFoodMenuScreen(
              restaurant: state.extra as SocieatyRestaurant,
            ),
            routes: [
              GoRoute(
                path: 'order',
                builder: (context, state) => CreateTransactionScreen(
                  restaurant: state.extra as SocieatyRestaurant,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
