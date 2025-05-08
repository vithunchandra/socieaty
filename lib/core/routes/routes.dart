import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socieaty/features/account/restaurant/view/restaurant_account_screen.dart';
import 'package:socieaty/features/admin/view/configure_content_screen.dart';
import 'package:socieaty/features/admin/view/configure_livestreams_screen.dart';
import 'package:socieaty/features/admin/view/configure_unverified_restaurant_screen.dart';
import 'package:socieaty/features/admin/view/configure_user_screen.dart';
import 'package:socieaty/features/admin/view/verify_restaurant_screen.dart';
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
import 'package:socieaty/features/customer/view/customer_wallet_screen.dart';
import 'package:socieaty/features/customer/view/update_customer_profile_screen.dart';
import 'package:socieaty/features/food_menu/customer/view/outlet_food_menu_screen.dart';
import 'package:socieaty/features/home/admin/view/admin_dashboard_screen.dart';
import 'package:socieaty/features/livestream/model/live_room.dart';
import 'package:socieaty/features/livestream/view/live_screen.dart';
import 'package:socieaty/features/livestream/view/livestream_widget.dart';
import 'package:socieaty/features/map/view/tracking_map.dart';
import 'package:socieaty/features/post/post/view/post_detail_widget.dart';
import 'package:socieaty/features/post/post/view/update_post_screen.dart';
import 'package:socieaty/features/restaurant/view/rejected_restaurant_screen.dart';
import 'package:socieaty/features/restaurant/view/unverified_restaurant_screen.dart';
import 'package:socieaty/features/restaurant/view/update_restaurant_data_screen.dart';
import 'package:socieaty/features/shop/customer/view/map_exploration.screen.dart';
import 'package:socieaty/features/support-ticket/model/support_ticket.dart';
import 'package:socieaty/features/support-ticket/view/create_support_ticket_screen.dart';
import 'package:socieaty/features/support-ticket/view/customer_support_screen.dart';
import 'package:socieaty/features/support-ticket/view/support_chat_screen.dart';
import 'package:socieaty/features/topup/view/track_topup_screen.dart';
import 'package:socieaty/features/transaction-message/view/chat_screen.dart';
import 'package:socieaty/features/home/customer/view/home_screen.dart';
import 'package:socieaty/features/home/restaurant/view/restaurant_dashboard_screen.dart';
import 'package:socieaty/features/livestream/view/livestream_home_screen.dart';
import 'package:socieaty/features/map/view/select_location.dart';
import 'package:socieaty/features/post/post/view/post_screen.dart';
import 'package:socieaty/features/qr_code_scanner/view/qr_code_scanner_screen.dart';
import 'package:socieaty/features/reservation/customer/view/create_reservation_screen.dart';
import 'package:socieaty/features/reservation/customer/view/outlet_reserve_screen.dart';
import 'package:socieaty/features/reservation/customer/view/reservation_food_selection_screen.dart';
import 'package:socieaty/features/reservation/customer/view/reservations_history_screen.dart';
import 'package:socieaty/features/reservation/customer/view/track_reservation_screen.dart';
import 'package:socieaty/features/reservation/restaurant/view/reservation_management_screen.dart';
import 'package:socieaty/features/reservation/restaurant/view/reservation_navigator_screen.dart';
import 'package:socieaty/features/reservation/restaurant/view/reservation_schedule_calender_screen.dart';
import 'package:socieaty/features/reservation/restaurant/view/reservations_schedule_screen.dart';
import 'package:socieaty/features/reservation/restaurant/view/restaurant_reservation_history_screen.dart';
import 'package:socieaty/features/restaurant/model/reservation_config.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';
import 'package:socieaty/features/restaurant/view/restaurant_scaffold_with_navbar.dart';
import 'package:socieaty/features/food_menu/restaurant/view/create_food_menu_screen.dart';
import 'package:socieaty/features/food_menu/restaurant/view/owner_food_menu_screen.dart';
import 'package:socieaty/features/food_menu/restaurant/view/update_food_menu_screen.dart';
import 'package:socieaty/features/restaurant/view/update_reservation_config_screen.dart';
import 'package:socieaty/features/shop/customer/view/shop_screen.dart';
import 'package:socieaty/features/shop/customer/view/shop_search_screen.dart';
import 'package:socieaty/features/food-order/customer/view/create_food_order_screen.dart';
import 'package:socieaty/features/food-order/restaurant/view/restaurant_food_order_screen.dart';
import 'package:socieaty/features/transaction/model/transaction.dart';
import 'package:socieaty/features/transaction/view/transaction_report_screen.dart';
import 'package:socieaty/features/transaction/view/transaction_list_screen.dart';
import 'package:socieaty/features/transaction_review/view/restaurant_rating_screen.dart';
import 'package:socieaty/features/user/view/profile_loader_screen.dart';
import 'package:socieaty/shared/widgets/create_screen.dart';
import 'package:socieaty/features/customer/view/customer_scaffold_with_navbar.dart';
import 'package:socieaty/features/food-order/customer/view/track_order_screen.dart';
import 'package:socieaty/features/food-order/restaurant/view/restaurant_food_order_history_screen.dart';
import 'package:socieaty/features/food-order/customer/view/order_history_screen.dart';
import 'package:socieaty/features/map/view/restaurant_location_screen.dart';

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
        path: '/restaurant-location',
        builder: (context, state) {
          final args = state.extra as RestaurantLocationScreenArgs;
          return RestaurantLocationScreen(args: args);
        },
      ),
      GoRoute(
        path: '/create_content',
        pageBuilder: (context, state) {
          final args = state.extra as CreateScreenArgs?;
          return NoTransitionPage(
            child: CreateScreen(args: args),
          );
        },
        routes: [
          GoRoute(
            path: 'live',
            pageBuilder: (context, state) => NoTransitionPage(
              child: LiveScreen(args: state.extra as LiveScreenArgs),
            ),
          ),
        ],
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
        routes: [
          GoRoute(
            path: 'update',
            builder: (context, state) =>
                UpdatePostScreen(args: state.extra as UpdatePostScreenArgs),
          ),
        ],
      ),
      GoRoute(
        path: '/admin',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AdminDashboardScreen(),
        ),
        routes: [
          GoRoute(
            path: 'configure-user',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ConfigureUserScreen(),
            ),
          ),
          GoRoute(
            path: 'configure-content',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ConfigureContentScreen(),
            ),
            routes: [
              GoRoute(
                path: 'detail',
                pageBuilder: (context, state) => NoTransitionPage(
                  child: PostDetailWidget(
                    args: state.extra as PostDetailWidgetArgs,
                  ),
                ),
              ),
              GoRoute(
                path: 'livestream',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ConfigureLivestreamsScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'detail',
                    pageBuilder: (context, state) => NoTransitionPage(
                      child: LivestreamWidget(state.extra as LiveRoom),
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: 'customer-support',
            pageBuilder: (context, state) => const NoTransitionPage(child: CustomerSupportScreen()),
            routes: [
              GoRoute(
                path: ':ticketId',
                pageBuilder: (context, state) => NoTransitionPage(
                  child: SupportChatScreen(ticket: state.extra as SupportTicket),
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'restaurant-verification',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ConfigureUnverifiedRestaurantScreen(),
            ),
            routes: [
              GoRoute(
                path: 'detail',
                pageBuilder: (context, state) => NoTransitionPage(
                  child: VerifyRestaurantScreen(
                    args: state.extra as VerifyRestaurantScreenArgs,
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'transaction-report',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TransactionReportScreen(),
            ),
            routes: [
              GoRoute(
                path: 'history',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: TransactionListScreen(),
                ),
              ),
            ],
          ),
        ],
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
                  GoRoute(
                    path: 'history/order',
                    pageBuilder: (context, state) => const NoTransitionPage(
                      child: OrderHistoryScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'history/reservation',
                    pageBuilder: (context, state) => const NoTransitionPage(
                      child: ReservationsHistoryScreen(),
                    ),
                  ),
                  GoRoute(
                    parentNavigatorKey: rootNavigatorKey,
                    path: 'map-exploration',
                    pageBuilder: (context, state) => const NoTransitionPage(
                      child: MapExplorationScreen(),
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
                  ),
                  GoRoute(
                    path: 'wallet',
                    pageBuilder: (context, state) => NoTransitionPage(
                      child: CustomerWalletScreen(),
                    ),
                    routes: [
                      GoRoute(
                        path: 'topup',
                        pageBuilder: (context, state) => NoTransitionPage(
                          child: TrackTopupScreen(topupId: state.extra as String),
                        ),
                      ),
                    ],
                  ),
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
                    builder: (context, state) => OwnerFoodMenuScreen(
                      args: state.extra as OwnerFoodMenuScreenArgs,
                    ),
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
                  GoRoute(
                    path: 'reservation',
                    parentNavigatorKey: rootNavigatorKey,
                    pageBuilder: (context, state) => const NoTransitionPage(
                      child: ReservationNavigatorScreen(),
                    ),
                    routes: [
                      GoRoute(
                          path: 'view',
                          parentNavigatorKey: rootNavigatorKey,
                          pageBuilder: (context, state) => NoTransitionPage(
                                child: ReservationsScheduleScreen(
                                  reservationConfig: state.extra as ReservationConfig,
                                ),
                              ),
                          routes: [
                            GoRoute(
                              path: 'calender',
                              parentNavigatorKey: rootNavigatorKey,
                              pageBuilder: (context, state) => NoTransitionPage(
                                child: ReservationScheduleCalenderScreen(
                                  reservationConfig: state.extra as ReservationConfig,
                                ),
                              ),
                            ),
                          ]),
                      GoRoute(
                        path: 'manage',
                        parentNavigatorKey: rootNavigatorKey,
                        pageBuilder: (context, state) => const NoTransitionPage(
                          child: ReservationManagementScreen(),
                        ),
                        routes: [
                          GoRoute(
                            path: 'history',
                            parentNavigatorKey: rootNavigatorKey,
                            pageBuilder: (context, state) => const NoTransitionPage(
                              child: RestaurantReservationHistoryScreen(),
                            ),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'config/update',
                        parentNavigatorKey: rootNavigatorKey,
                        pageBuilder: (context, state) => NoTransitionPage(
                          child: UpdateReservationConfigScreen(
                            reservationConfig: state.extra as ReservationConfig,
                          ),
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'transaction-report',
                    parentNavigatorKey: rootNavigatorKey,
                    pageBuilder: (context, state) => const NoTransitionPage(
                      child: TransactionReportScreen(),
                    ),
                    routes: [
                      GoRoute(
                        path: 'history',
                        pageBuilder: (context, state) => const NoTransitionPage(
                          child: TransactionListScreen(),
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
                  child: RestaurantFoodOrderScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'history',
                    pageBuilder: (context, state) => const NoTransitionPage(
                      child: RestaurantFoodOrderHistoryScreen(),
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
        path: '/restaurant/unverified',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: UnverifiedRestaurantScreen(),
        ),
      ),
      GoRoute(
        path: '/restaurant/rejected',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: RejectedRestaurantScreen(),
        ),
        routes: [
          GoRoute(
            path: 'update',
            pageBuilder: (context, state) => NoTransitionPage(
              child: UpdateRestaurantDataScreen(
                restaurant: state.extra as SocieatyRestaurant,
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/customer-support',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: CustomerSupportScreen(),
        ),
        routes: [
          GoRoute(
            path: 'create',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CreateSupportTicketScreen(),
            ),
          ),
          GoRoute(
            path: ':ticketId',
            pageBuilder: (context, state) => NoTransitionPage(
              child: SupportChatScreen(ticket: state.extra as SupportTicket),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/track-map',
        builder: (context, state) => TrackingMap(
          args: state.extra as TrackingMapArgs,
        ),
      ),
      GoRoute(
        path: '/track-order',
        builder: (context, state) => TrackOrderScreen(
          orderId: state.extra as String,
        ),
        routes: [],
      ),
      GoRoute(
        path: '/transaction/message',
        builder: (context, state) => ChatScreen(
          transaction: state.extra as Transaction,
        ),
      ),
      GoRoute(
        path: '/transaction/review',
        builder: (context, state) => RestaurantRatingScreen(
          transaction: state.extra as Transaction,
        ),
      ),
      GoRoute(
        path: '/track-reservation',
        builder: (context, state) => TrackReservationScreen(
          reservationId: state.extra as String,
        ),
        routes: [],
      ),
      GoRoute(
        path: '/qr-code-scanner',
        builder: (context, state) => QrCodeScannerScreen(
          args: state.extra as QrCodeScannerArgs? ??
              const QrCodeScannerArgs(
                title: 'Scan QR Code',
                helperMessage: 'Align QR code within the frame to scan',
              ),
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
              args: state.extra as OutletFoodMenuScreenArgs,
            ),
            routes: [
              GoRoute(
                path: 'order',
                builder: (context, state) => CreateFoodOrderScreen(
                  restaurant: state.extra as SocieatyRestaurant,
                ),
              ),
              GoRoute(
                path: 'reserve',
                builder: (context, state) => OutletReserveScreen(
                  restaurant: state.extra as SocieatyRestaurant,
                ),
                routes: [
                  GoRoute(
                    path: 'food-selection',
                    builder: (context, state) => ReservationFoodSelectionScreen(
                      args: state.extra as ReservationFoodSelectionScreenArgs,
                    ),
                  ),
                  GoRoute(
                    path: 'create',
                    builder: (context, state) => CreateReservationScreen(
                      args: state.extra as CreateReservationScreenArgs,
                    ),
                  ),
                  GoRoute(
                    path: 'track',
                    builder: (context, state) => TrackReservationScreen(
                      reservationId: state.extra as String,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
