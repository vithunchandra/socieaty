import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/account/customer/viewmodel/account_view_model.dart';
import 'package:socieaty/features/authentication/provider/get_user_data_provider.dart';
import 'package:socieaty/features/authentication/provider/session_provider.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final admin = ref.watch(authLocalRepositoryProvider).getUserData();
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

    if (admin == null) {
      context.go('/landing');
    }

    return ref.watch(getUserDataProvider(admin!.id)).when(
          data: (userData) {
            return _buildDashboardScreen(context, userData.name, isLoading);
          },
          loading: () => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stackTrace) {
            debugPrint(error.toString());
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error loading admin data'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(getUserDataProvider(admin.id)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          },
          skipError: true,
        );
  }

  void logout() {
    ref.read(accountViewModelProvider.notifier).signout();
  }

  Widget _buildDashboardScreen(BuildContext context, String adminName, bool isLoading) {
    return Scaffold(
      backgroundColor: AppPallete.neutralColor.shade50,
      appBar: AppBar(
        backgroundColor: AppPallete.neutralColor.shade50,
        surfaceTintColor: AppPallete.neutralColor.shade50,
        title: Text(
          'Dashboard',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        actions: [
          isLoading
              ? const LoadingIndicatorWidget(size: 24)
              : IconButton(
                  onPressed: () => logout(),
                  icon: const Icon(Icons.logout, color: AppPallete.primaryColor),
                ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(context, adminName),
              const SizedBox(height: 24),
              Text(
                'Management Options',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildManagementOptions(context),
              const SizedBox(height: 24),
              Text(
                'Quick Statistics',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildEmptyStatisticsState(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, String adminName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppPallete.primaryColor,
            AppPallete.primaryColor.shade500,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppPallete.primaryColor.withAlpha(50),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.admin_panel_settings,
                color: Colors.white.withAlpha(200),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Admin Dashboard',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withAlpha(200),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Welcome, $adminName',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your application and monitor activities',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withAlpha(220),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementOptions(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.0,
      children: [
        _buildOptionCard(
          context,
          Icons.people,
          'User Configuration',
          AppPallete.secondaryColor,
          onTap: () {
            // Navigate to user configuration screen
          },
        ),
        _buildOptionCard(
          context,
          Icons.bar_chart,
          'Income Report',
          AppPallete.infoColor,
          onTap: () {
            // Navigate to income report screen
          },
        ),
        _buildOptionCard(
          context,
          Icons.article,
          'Content Configuration',
          AppPallete.warningColor,
          onTap: () {
            // Navigate to content configuration screen
          },
        ),
        _buildOptionCard(
          context,
          Icons.support_agent,
          'Customer Support',
          AppPallete.errorColor,
          onTap: () {
            // Navigate to customer support screen
          },
        ),
      ],
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    IconData icon,
    String label,
    Color color, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppPallete.neutralColor.shade300.withAlpha(30),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStatisticsState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppPallete.neutralColor.shade300.withAlpha(30),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.insights,
            size: 48,
            color: AppPallete.neutralColor.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'No statistics available',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppPallete.neutralColor.shade700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Statistics will be displayed here once data is available',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppPallete.neutralColor.shade600,
                ),
          ),
        ],
      ),
    );
  }
}
