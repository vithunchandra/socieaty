import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/shared/widgets/header_icon_widget.dart';
import 'package:flutter/scheduler.dart';

class OutletScreen extends StatefulWidget {
  const OutletScreen({super.key});

  @override
  State<OutletScreen> createState() => _OutletScreenState();
}

class _OutletScreenState extends State<OutletScreen> with SingleTickerProviderStateMixin {
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
    double collapsedPercentage = _scrollController.offset / (screenHeight * mainHeaderHeightPercentage);

    SchedulerBinding.instance.addPostFrameCallback((_) {
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
      } else if (_isCollapsed && _scrollController.offset < screenHeight * mainHeaderHeightPercentage - 56) {
        setState(() {
          _isCollapsed = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppPallete.neutralColor.shade50,
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            // Restaurant Header
            SliverAppBar(
              expandedHeight: screenHeight * mainHeaderHeightPercentage + 48,
              pinned: true,
              title: _isCollapsed
                  ? Text(
                      "Socieaty",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black),
                    )
                  : null,
              surfaceTintColor: Colors.transparent,
              backgroundColor: _isAlmostCollapsed ? AppPallete.neutralColor.shade50 : AppPallete.neutralColor.shade800,
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
                                Colors.black.withAlpha(178), // 0.7 opacity
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
                                  "Socieaty",
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
                                      Icon(Icons.check_circle, color: AppPallete.primaryColor, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Open Now | 12pm - 1am",
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
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                                  onPressed: () {},
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.fastfood, size: 20),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Atur Menu",
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
                                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16.0),
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
                      tabs: const [
                        Tab(icon: Icon(Icons.grid_on_outlined)),
                        Tab(icon: Icon(Icons.fastfood_outlined)),
                        Tab(icon: Icon(Icons.reviews_outlined)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              // Posts Tab
              CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Container(
                          height: 200,
                          margin: const EdgeInsets.only(bottom: 8),
                          color: Colors.white,
                          child: Center(child: Text('Post ${index + 1}')),
                        ),
                        childCount: 10,
                      ),
                    ),
                  ),
                ],
              ),
              // Menu Tab
              CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Container(
                          height: 100,
                          margin: const EdgeInsets.only(bottom: 8),
                          color: Colors.white,
                          child: Center(child: Text('Menu Item ${index + 1}')),
                        ),
                        childCount: 10,
                      ),
                    ),
                  ),
                ],
              ),
              // Reviews Tab
              CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Container(
                          height: 150,
                          margin: const EdgeInsets.only(bottom: 8),
                          color: Colors.white,
                          child: Center(child: Text('Review ${index + 1}')),
                        ),
                        childCount: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
