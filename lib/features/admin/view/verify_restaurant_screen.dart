import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/converter.dart';
import 'package:socieaty/core/utils/location_handler.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/admin/viewmodel/verify_restaurant_view_model.dart';
import 'package:socieaty/features/map/view/restaurant_location_screen.dart';
import 'package:socieaty/features/restaurant/model/socieaty_restaurant.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/header_icon_widget.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';
import 'package:socieaty/shared/widgets/profile_picture_widget.dart';

class VerifyRestaurantScreenArgs {
  final SocieatyRestaurant restaurant;
  final VoidCallback onUpdateVerificationStatus;

  const VerifyRestaurantScreenArgs(
      {required this.restaurant, required this.onUpdateVerificationStatus});
}

class VerifyRestaurantScreen extends ConsumerStatefulWidget {
  final VerifyRestaurantScreenArgs args;

  const VerifyRestaurantScreen({
    super.key,
    required this.args,
  });

  @override
  ConsumerState<VerifyRestaurantScreen> createState() => _VerifyRestaurantScreenState();
}

class _VerifyRestaurantScreenState extends ConsumerState<VerifyRestaurantScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;
  String _locationName = "";

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    getLocationName();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final expandedHeight = 250.0;
    if (_scrollController.offset >= expandedHeight - kToolbarHeight && !_isCollapsed) {
      setState(() {
        _isCollapsed = true;
      });
    } else if (_scrollController.offset < expandedHeight - kToolbarHeight && _isCollapsed) {
      setState(() {
        _isCollapsed = false;
      });
    }
  }

  void getLocationName() async {
    var location =
        await LocationHandler.getAddressFromLatLng(widget.args.restaurant.restaurantData.location);
    if (location != null && mounted) {
      setState(() {
        _locationName = "${location.street}, ${location.subLocality}, ${location.locality}";
      });
    }
  }

  void _openMap() {
    context.push(
      '/restaurant-location',
      extra: RestaurantLocationScreenArgs(
        location: widget.args.restaurant.restaurantData.location,
        restaurantName: widget.args.restaurant.name,
      ),
    );
  }

  Future<void> verifyRestaurant() async {
    ref
        .read(verifyRestaurantViewModelProvider(widget.args.restaurant.restaurantData.id).notifier)
        .acceptVerification();
  }

  Future<void> rejectRestaurant() async {
    ref
        .read(verifyRestaurantViewModelProvider(widget.args.restaurant.restaurantData.id).notifier)
        .rejectVerification();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(verifyRestaurantViewModelProvider(widget.args.restaurant.restaurantData.id),
        (previous, next) {
      switch (next.verifyRestaurantState) {
        case SuccessState():
          context.pop();
          widget.args.onUpdateVerificationStatus();
        case ErrorState(message: final message):
          showSnackbar(context, message);

        default:
          break;
      }

      switch (next.rejectVerificationState) {
        case SuccessState():
          context.pop();
          widget.args.onUpdateVerificationStatus();
        case ErrorState(message: final message):
          showSnackbar(context, message);

        default:
          break;
      }
    });

    return Scaffold(
      backgroundColor: AppPallete.neutralColor.shade50,
      body: _buildVerificationContent(),
      bottomNavigationBar: _buildActionButtons(),
    );
  }

  Widget _buildVerificationContent() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        _buildAppBar(),
        SliverPadding(
          padding: EdgeInsets.only(top: 16),
          sliver: SliverToBoxAdapter(
            child: _buildVerificationDetails(),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
      title: _isCollapsed
          ? Text(
              'Verify Restaurant',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            )
          : null,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Restaurant Banner
            Image.network(
              widget.args.restaurant.restaurantData.restaurantBannerUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  "assets/images/restaurant_2.jpg",
                  fit: BoxFit.cover,
                );
              },
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(0),
                    Colors.black.withAlpha(255),
                  ],
                  stops: const [0.3, 1.0],
                ),
              ),
            ),
            // Restaurant Basic Info
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ProfilePictureWidget(
                        user: UserConverter.restaurantToUser(widget.args.restaurant),
                        radius: 24,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.args.restaurant.name,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              widget.args.restaurant.email,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                            SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppPallete.warningColor.withAlpha(76),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppPallete.warningColor,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Pending Verification',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppPallete.warningColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      leading: HeaderIconWidget(
        isScrollCompleted: _isCollapsed,
        icon: Icons.arrow_back,
        onPressed: () => context.pop(),
      ),
      actions: [
        HeaderIconWidget(
          isScrollCompleted: _isCollapsed,
          icon: Icons.verified_outlined,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildVerificationDetails() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Restaurant Details Header
          _buildDetailsSectionHeader(
            title: 'Restaurant Details',
            icon: Icons.restaurant,
            color: AppPallete.primaryColor,
          ),
          _buildContactInfo(),

          Divider(height: 1, color: AppPallete.neutralColor.shade100),

          // Business Hours & Location Section
          _buildDetailsSectionHeader(
            title: 'Business Information',
            icon: Icons.business,
            color: AppPallete.infoColor,
          ),
          _buildBusinessInfoDetails(),

          Divider(height: 1, color: AppPallete.neutralColor.shade100),

          // Banking Details Section
          _buildDetailsSectionHeader(
            title: 'Banking Information',
            icon: Icons.account_balance,
            color: AppPallete.secondaryColor,
          ),
          _buildBankingDetails(),

          Divider(height: 1, color: AppPallete.neutralColor.shade100),

          // Restaurant Themes
          _buildDetailsSectionHeader(
            title: 'Themes',
            icon: Icons.category,
            color: AppPallete.warningColor,
          ),
          _buildThemesSection(),
        ],
      ),
    );
  }

  Widget _buildDetailsSectionHeader({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.phone,
            iconColor: AppPallete.primaryColor,
            label: 'Phone Number',
            value: widget.args.restaurant.phoneNumber,
          ),
          SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.badge,
            iconColor: AppPallete.primaryColor,
            label: 'User ID',
            value: widget.args.restaurant.restaurantData.id,
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessInfoDetails() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        children: [
          GestureDetector(
            onTap: _openMap,
            child: _buildInfoRow(
              icon: Icons.location_on,
              iconColor: AppPallete.infoColor,
              label: 'Location',
              value: _locationName.isEmpty ? 'Loading address...' : _locationName,
              clickable: true,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildInfoRow(
                  icon: Icons.access_time,
                  iconColor: AppPallete.infoColor,
                  label: 'Opening Time',
                  value: widget.args.restaurant.restaurantData.openTime,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildInfoRow(
                  icon: Icons.access_time_filled,
                  iconColor: AppPallete.infoColor,
                  label: 'Closing Time',
                  value: widget.args.restaurant.restaurantData.closeTime,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.calendar_today,
            iconColor: AppPallete.infoColor,
            label: 'Reservations',
            value: widget.args.restaurant.restaurantData.isReservationAvailable
                ? 'Available'
                : 'Not Available',
            valueColor: widget.args.restaurant.restaurantData.isReservationAvailable
                ? AppPallete.successColor
                : AppPallete.errorColor,
          ),
        ],
      ),
    );
  }

  Widget _buildBankingDetails() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.account_balance,
            iconColor: AppPallete.secondaryColor,
            label: 'Bank Name',
            value: widget.args.restaurant.restaurantData.payoutBank.name.toUpperCase(),
          ),
          SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.credit_card,
            iconColor: AppPallete.secondaryColor,
            label: 'Account Number',
            value: widget.args.restaurant.restaurantData.accountNumber,
          ),
        ],
      ),
    );
  }

  Widget _buildThemesSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: widget.args.restaurant.restaurantData.themes.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'No themes selected',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppPallete.neutralColor.shade400,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.args.restaurant.restaurantData.themes.map((theme) {
                return Chip(
                  label: Text(theme.name),
                  backgroundColor: AppPallete.warningColor.withAlpha(25),
                  side: BorderSide(color: AppPallete.warningColor.withAlpha(76)),
                  labelStyle: TextStyle(
                    color: AppPallete.neutralColor.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                  avatar: Icon(
                    Icons.local_dining,
                    size: 16,
                    color: AppPallete.warningColor,
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color? valueColor,
    bool clickable = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 16,
            color: iconColor,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppPallete.neutralColor.shade600,
                    ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: valueColor ?? AppPallete.neutralColor.shade800,
                      fontWeight: FontWeight.w500,
                      decoration: clickable ? TextDecoration.underline : null,
                    ),
              ),
              if (clickable)
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    "Tap to view on map",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppPallete.primaryColor,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final isRejecting = ref
        .watch(verifyRestaurantViewModelProvider(widget.args.restaurant.restaurantData.id))
        .rejectVerificationState is LoadingState;
    final isVerifying = ref
        .watch(verifyRestaurantViewModelProvider(widget.args.restaurant.restaurantData.id))
        .verifyRestaurantState is LoadingState;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: isRejecting ? null : rejectRestaurant,
                child: isRejecting
                    ? const LoadingIndicatorWidget(size: 16, color: AppPallete.errorColor)
                    : Text('Reject'),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: isVerifying ? null : verifyRestaurant,
                child: isVerifying
                    ? const LoadingIndicatorWidget(size: 16, color: AppPallete.successColor)
                    : Text('Verify'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
