import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/core/utils/time_utils.dart';
import 'package:socieaty/features/post/post/view/post_sliver_grid_widget.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';
import 'package:socieaty/features/restaurant/view/outlet_home_widget.dart';
import 'package:socieaty/shared/widgets/header_icon_widget.dart';

class OwnerOutletScreen extends ConsumerStatefulWidget {
  final SocieatyRestaurant restaurant;
  const OwnerOutletScreen({super.key, required this.restaurant});

  @override
  ConsumerState<OwnerOutletScreen> createState() => _OwnerOutletScreenState();
}

class _OwnerOutletScreenState extends ConsumerState<OwnerOutletScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final mainHeaderHeightPercentage = 0.5;
  bool _isCollapsed = false;
  bool _isAlmostCollapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final screenHeight = MediaQuery.of(context).size.height;
    double collapsedPercentage =
        _scrollController.offset / (screenHeight * mainHeaderHeightPercentage);

    if (mounted) {
      if (collapsedPercentage >= 0.65) {
        if (!_isAlmostCollapsed) {
          setState(() {
            _isAlmostCollapsed = true;
          });
        }
      } else if (_isAlmostCollapsed && collapsedPercentage < 0.65) {
        setState(() {
          _isAlmostCollapsed = false;
        });
      }

      if (_scrollController.offset >= screenHeight * mainHeaderHeightPercentage - 56) {
        if (!_isCollapsed) {
          setState(() {
            _isCollapsed = true;
          });
        }
      } else if (_isCollapsed &&
          _scrollController.offset < screenHeight * mainHeaderHeightPercentage - 56) {
        setState(() {
          _isCollapsed = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOpen = isNowBetween(widget.restaurant.restaurantData.openTime.toTimeOfDay(),
        widget.restaurant.restaurantData.closeTime.toTimeOfDay());

    final List<OutletTabs> tabs = [
      OutletTabs(
        title: "Home",
        icon: Icons.home_outlined,
        widget: OutletHomeWidget(
          restaurant: widget.restaurant,
          onMenuCarouselItemTapped: () {
            context.push(
              '/restaurant/dashboard/outlet/menu',
              extra: widget.restaurant,
            );
          },
          onPostCarouselItemTapped: () {
            DefaultTabController.of(context).animateTo(1);
          },
          onReviewCarouselItemTapped: () {},
        ),
      ),
      OutletTabs(
        title: "Post",
        icon: Icons.grid_view_outlined,
        widget: PostSliverGridWidget(
          authorId: widget.restaurant.id,
        ),
      ),
      OutletTabs(title: "Reviews", icon: Icons.reviews_outlined, widget: Container()),
    ];
    final screenHeight = MediaQuery.of(context).size.height;

    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: AppPallete.neutralColor.shade50,
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverAppBar(
                  expandedHeight: screenHeight * mainHeaderHeightPercentage + 48,
                  pinned: true,
                  title: _isCollapsed
                      ? Text(
                          "Socieaty",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: Colors.black),
                        )
                      : null,
                  surfaceTintColor: Colors.transparent,
                  backgroundColor: _isAlmostCollapsed
                      ? AppPallete.neutralColor.shade50
                      : AppPallete.neutralColor.shade800,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      clipBehavior: Clip.none,
                      children: [
                        // Background image with dark overlay
                        Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              "assets/images/restaurant_2.jpg",
                              fit: BoxFit.cover,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withAlpha(0),
                                    Colors.black.withAlpha(255), // 0.7 opacity
                                  ],
                                  stops: const [0.3, 1.0],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Restaurant info
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 130,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.restaurant.name,
                                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Jln. Ngagel Jaya Tengah No.158",
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Colors.white,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withAlpha(128),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle,
                                              color: AppPallete.primaryColor, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${isOpen ? "Open Now" : "Closed"} | ${widget.restaurant.restaurantData.openTime} - ${widget.restaurant.restaurantData.closeTime}",
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  color: Colors.white,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: 68,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        color: AppPallete.successColor,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "4.6",
                                              style:
                                                  Theme.of(context).textTheme.titleMedium?.copyWith(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(Icons.star, color: Colors.white, size: 20),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        color: Colors.white,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "9403",
                                              style:
                                                  Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                            ),
                                            Text(
                                              "Reviews",
                                              style: Theme.of(context).textTheme.bodyMedium,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 56,
                          child: SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: FilledButton(
                                      onPressed: () {
                                        context.push(
                                          '/restaurant/dashboard/outlet/menu',
                                          extra: widget.restaurant,
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 12.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.fastfood, size: 20),
                                            const SizedBox(width: 4),
                                            Text(
                                              "Tambah Menu",
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  FilledButton(
                                    onPressed: () {},
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 4, horizontal: 16.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.post_add, size: 20),
                                          const SizedBox(width: 4),
                                          Text("Post"),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    collapseMode: CollapseMode.pin,
                  ),
                  leading: HeaderIconWidget(
                    isScrollCompleted: _isCollapsed,
                    icon: Icons.arrow_back,
                    onPressed: () => context.pop(),
                  ),
                  actions: [
                    HeaderIconWidget(
                      isScrollCompleted: _isCollapsed,
                      icon: Icons.reviews,
                      onPressed: () {},
                    ),
                    HeaderIconWidget(
                      isScrollCompleted: _isCollapsed,
                      icon: Icons.share,
                      onPressed: () {},
                    ),
                  ],
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(48),
                    child: Material(
                      elevation: 1.0,
                      child: Container(
                        color: AppPallete.neutralColor.shade50,
                        child: TabBar(
                          labelColor: AppPallete.primaryColor,
                          indicatorColor: AppPallete.primaryColor,
                          overlayColor: WidgetStateProperty.resolveWith<Color?>(
                            (Set<WidgetState> states) {
                              // Set overlayColor to transparent for all states
                              return Colors.transparent;
                            },
                          ),
                          dividerColor: Colors.transparent,
                          tabs: tabs.map((tab) => Tab(icon: Icon(tab.icon))).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: tabs.map((tab) {
              return SafeArea(
                top: false,
                bottom: false,
                child: Builder(
                  builder: (context) {
                    return CustomScrollView(
                      slivers: [
                        SliverOverlapInjector(
                          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                        ),
                        if (tab.title == "Home")
                          SliverToBoxAdapter(
                            child: OutletHomeWidget(
                              restaurant: widget.restaurant,
                              onMenuCarouselItemTapped: () {
                                context.push(
                                  '/restaurant/dashboard/outlet/menu',
                                  extra: widget.restaurant,
                                );
                              },
                              onPostCarouselItemTapped: () {
                                DefaultTabController.of(context).animateTo(1);
                              },
                              onReviewCarouselItemTapped: () {},
                            ),
                          ),
                        if (tab.title == "Post") tab.widget
                      ],
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class OutletTabs {
  final String title;
  final IconData icon;
  final Widget widget;

  OutletTabs({required this.title, required this.icon, required this.widget});
}
