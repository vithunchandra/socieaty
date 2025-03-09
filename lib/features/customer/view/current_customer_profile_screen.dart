import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/account/customer/viewmodel/account_view_model.dart';
import 'package:socieaty/features/authentication/provider/session_provider.dart';
import 'package:socieaty/features/customer/model/socieaty_customer.dart';
import 'package:socieaty/features/post/post/view/post_grid_widget.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:socieaty/shared/widgets/custom_text_field.dart';
import 'package:socieaty/shared/widgets/profile_avatar_placeholder_widget.dart';

class CurrentCustomerProfileScreen extends ConsumerStatefulWidget {
  final SocieatyCustomer user;
  const CurrentCustomerProfileScreen({super.key, required this.user});

  @override
  ConsumerState<CurrentCustomerProfileScreen> createState() => _CurrentCustomerProfileScreenState();
}

class _CurrentCustomerProfileScreenState extends ConsumerState<CurrentCustomerProfileScreen> {
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
    debugPrint('Profile header size: ${_profileHeaderSize?.height}');
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

  void _showBioDialog(BuildContext context) {
    final TextEditingController bioController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Bio'),
          content: CustomTextField(
            controller: bioController,
            hintText: 'Enter your bio...',
            minLines: 1,
            maxLines: 3,
            prefixIcon: const Icon(Icons.description_outlined),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppPallete.neutralColor.shade600),
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    bool isLoading = ref.watch(accountViewModelProvider).isSignedOut is LoadingState;

    ref.listen(accountViewModelProvider, (_, next) {
      switch (next.isSignedOut) {
        case SuccessState<bool>():
          ref.invalidate(getSessionDataProvider);
          context.go('/landing');
        case ErrorState():
          ref.invalidate(getSessionDataProvider);
          context.go('/landing');
        case LoadingState():
        case IdleState():
      }
    });

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppPallete.neutralColor.shade50,
        appBar: AppBar(
          backgroundColor: AppPallete.neutralColor.shade50,
          surfaceTintColor: AppPallete.neutralColor.shade50,
          title: _showSmallProfile
              ? Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppPallete.neutralColor.shade200,
                      backgroundImage: widget.user.profilePictureUrl != null
                          ? NetworkImage(widget.user.profilePictureUrl!)
                          : null,
                      child: widget.user.profilePictureUrl == null
                          ? ProfileAvatarPlaceholderWidget(name: widget.user.name)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(widget.user.name),
                  ],
                )
              : Text(widget.user.name),
          centerTitle: true,
          actions: [
            DropdownButtonHideUnderline(
              child: DropdownButton2(
                customButton: Icon(
                  Icons.menu,
                  color: AppPallete.neutralColor.shade800,
                ),
                items: [
                  DropdownMenuItem(
                    value: 'balance',
                    child: Row(
                      children: [
                        Icon(Icons.account_balance_wallet_outlined,
                            color: AppPallete.neutralColor.shade800),
                        const SizedBox(width: 10),
                        Text('Balance', style: Theme.of(context).textTheme.titleSmall),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout_outlined, color: AppPallete.neutralColor.shade800),
                        const SizedBox(width: 10),
                        Text('Log Out', style: Theme.of(context).textTheme.titleSmall),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  switch (value) {
                    case 'balance':
                      break;
                    case 'logout':
                      ref.read(accountViewModelProvider.notifier).signout();
                      break;
                  }
                },
                dropdownStyleData: DropdownStyleData(
                  width: 160,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  elevation: 1,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  offset: const Offset(0, 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: isLoading
            ? const LoadingIndicatorWidget()
            : NestedScrollView(
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
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: AppPallete.neutralColor.shade200,
                                backgroundImage: widget.user.profilePictureUrl != null
                                    ? NetworkImage(widget.user.profilePictureUrl!)
                                    : null,
                                child: widget.user.profilePictureUrl == null
                                    ? ProfileAvatarPlaceholderWidget(name: widget.user.name)
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text("@${widget.user.email}",
                                style: Theme.of(context).textTheme.titleMedium),
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
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        context.push('/customer/profile/update',
                                            extra: widget.user);
                                      },
                                      child: const Text("Edit profile"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            widget.user.customerData.bio.isEmpty
                                ? TextButton(
                                    onPressed: () => _showBioDialog(context),
                                    child: const Text("+ Add bio"),
                                  )
                                : SizedBox(
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
                            Tab(icon: Icon(Icons.lock_outline)),
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
                    Center(child: Text("Locked Content")),
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
