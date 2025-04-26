import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/features/customer/model/socieaty_customer.dart';
import 'package:socieaty/features/post/post/view/post_grid_widget.dart';
import 'package:socieaty/shared/widgets/profile_picture_widget.dart';

class OtherCustomerProfileScreen extends ConsumerStatefulWidget {
  final SocieatyCustomer user;
  const OtherCustomerProfileScreen({super.key, required this.user});

  @override
  ConsumerState<OtherCustomerProfileScreen> createState() => _OtherCustomerProfileScreenState();
}

class _OtherCustomerProfileScreenState extends ConsumerState<OtherCustomerProfileScreen> {
  late ScrollController _scrollController;
  bool _showSmallProfile = false;
  Size? _profileHeaderSize;

  final GlobalKey _profileHeaderKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getProfileHeaderSize();
    });
  }

  void _getProfileHeaderSize() {
    if (_profileHeaderKey.currentContext != null) {
      final RenderBox renderBox = _profileHeaderKey.currentContext!.findRenderObject() as RenderBox;
      final size = renderBox.size;
      setState(() {
        _profileHeaderSize = size;
      });
    }
  }

  void _scrollListener() {
    final threshold = _profileHeaderSize?.height ?? MediaQuery.of(context).size.height * 0.4;
    if (_scrollController.offset > threshold && !_showSmallProfile) {
      setState(() {
        _showSmallProfile = true;
      });
    } else if (_scrollController.offset <= threshold && _showSmallProfile) {
      setState(() {
        _showSmallProfile = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppPallete.neutralColor.shade50,
        appBar: AppBar(
          backgroundColor: AppPallete.neutralColor.shade50,
          surfaceTintColor: AppPallete.neutralColor.shade50,
          title: _showSmallProfile
              ? Row(
                  children: [
                    ProfilePictureWidget(
                      radius: 16,
                      user: UserConverter.customerToUser(widget.user),
                    ),
                    const SizedBox(width: 8),
                    Text(widget.user.name),
                  ],
                )
              : Text(widget.user.name),
          centerTitle: true,
        ),
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Container(
                  key: _profileHeaderKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      PhysicalModel(
                        color: AppPallete.neutralColor.shade50,
                        elevation: 2.0,
                        shadowColor: AppPallete.neutralColor,
                        borderRadius: BorderRadius.circular(50),
                        child: ProfilePictureWidget(
                          radius: 50,
                          user: UserConverter.customerToUser(widget.user),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text("@${widget.user.email}", style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatColumn("Following", "1"),
                          _buildStatColumn("Followers", "0"),
                          _buildStatColumn("Likes", "0"),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: screenWidth * 0.6,
                        child: Text(
                          widget.user.customerData.bio,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    indicatorColor: AppPallete.primaryColor,
                    labelColor: AppPallete.primaryColor,
                    unselectedLabelColor: AppPallete.neutralColor.shade400,
                    tabs: const [
                      Tab(icon: Icon(Icons.grid_on)),
                      Tab(icon: Icon(Icons.favorite_border)),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              PostGridWidget(authorId: widget.user.id),
              Center(child: Text("Favorite Content")),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String count) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppPallete.neutralColor.shade50,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
