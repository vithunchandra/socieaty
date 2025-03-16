import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/transaction_review/model/transaction_review.dart';
import 'package:socieaty/features/transaction_review/provider/get_all_restaurant_reviews_provider.dart';
import 'package:socieaty/features/transaction_review/viewstate/get_restaurant_reviews_query.dart';
import 'package:intl/intl.dart';
import 'package:socieaty/shared/widgets/custom_error_widget.dart';

class SliverRestaurantReviewsWidget extends ConsumerStatefulWidget {
  final String restaurantId;
  final bool showHeader;
  final bool showRatingSummary;

  const SliverRestaurantReviewsWidget({
    super.key,
    required this.restaurantId,
    this.showHeader = true,
    this.showRatingSummary = true,
  });

  @override
  ConsumerState<SliverRestaurantReviewsWidget> createState() =>
      _SliverRestaurantReviewsWidgetState();
}

class _SliverRestaurantReviewsWidgetState extends ConsumerState<SliverRestaurantReviewsWidget> {
  GetRestaurantReviewsQuery? _currentQuery;

  @override
  Widget build(BuildContext context) {
    final reviewsAsync =
        ref.watch(getAllRestaurantReviewsProvider(widget.restaurantId, _currentQuery));

    // Always build these parts of UI regardless of data loading state
    List<Widget> headerWidgets = [
      const SizedBox(height: 16),
      if (widget.showHeader) _buildHeader(context),
      if (widget.showHeader) const SizedBox(height: 24),

      // Reviews section header
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Reviews',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppPallete.neutralColor.shade100,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              reviewsAsync.value?.length.toString() ?? '0',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      _buildReviewsFilter(context),
      const SizedBox(height: 24),
    ];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          ...headerWidgets,
          // Content area that changes based on loading state
          reviewsAsync.when(
            data: (reviews) {
              // Show rating summary only if there are reviews and showRatingSummary is true
              List<Widget> contentWidgets = [];

              if (reviews.isNotEmpty && widget.showRatingSummary) {
                contentWidgets.addAll([
                  _buildRatingSummary(
                      context,
                      reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length,
                      reviews.length),
                  const SizedBox(height: 24),
                  _buildRatingDistribution(context, reviews),
                  const SizedBox(height: 32),
                ]);
              }

              // Reviews or empty state
              if (reviews.isEmpty) {
                contentWidgets.add(_buildEmptyState(context));
              } else {
                contentWidgets.addAll(reviews.map((review) => _buildReviewItem(context, review)));
              }

              return Column(children: contentWidgets);
            },
            loading: () => Container(
              height: 300,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
            error: (error, stackTrace) => CustomErrorWidget(
              error: error.toString(),
              title: 'Could not load reviews',
              onPressed: () =>
                  ref.refresh(getAllRestaurantReviewsProvider(widget.restaurantId, _currentQuery)),
            ),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: 300,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppPallete.neutralColor.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.rate_review_outlined,
              color: AppPallete.neutralColor.shade400,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Reviews Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Be the first to share your experience',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppPallete.neutralColor.shade600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppPallete.primaryColor.withOpacity(0.05),
            AppPallete.primaryColor.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppPallete.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.restaurant_rounded,
              color: AppPallete.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer Reviews',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppPallete.primaryColor,
                      ),
                ),
                Text(
                  'See what others have experienced',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppPallete.neutralColor.shade700,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingDistribution(BuildContext context, List<TransactionReview> reviews) {
    final distribution = <int, int>{};
    for (int i = 1; i <= 5; i++) {
      distribution[i] = reviews.where((r) => r.rating == i).length;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppPallete.neutralColor.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppPallete.neutralColor.withAlpha(128),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rating Distribution',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          ...List.generate(5, (index) {
            final starCount = 5 - index;
            final count = distribution[starCount] ?? 0;
            final percentage = reviews.isEmpty ? 0.0 : count / reviews.length;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    child: Text(
                      '$starCount',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.star,
                    color: AppPallete.primaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: AppPallete.neutralColor.shade200,
                        color: AppPallete.primaryColor,
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 24,
                    child: Text(
                      '$count',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppPallete.neutralColor.shade700,
                          ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReviewsFilter(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(context, 'All', _currentQuery == null, () {
            setState(() {
              _currentQuery = null;
            });
            ref.refresh(getAllRestaurantReviewsProvider(widget.restaurantId, null));
          }),
          _buildFilterChip(context, '5 Star', _currentQuery != null && _currentQuery!.rating == 5,
              () {
            setState(() {
              _currentQuery = const GetRestaurantReviewsQuery(rating: 5);
            });
            ref.refresh(getAllRestaurantReviewsProvider(widget.restaurantId, _currentQuery));
          }),
          _buildFilterChip(context, '4 Star', _currentQuery != null && _currentQuery!.rating == 4,
              () {
            setState(() {
              _currentQuery = const GetRestaurantReviewsQuery(rating: 4);
            });
            ref.refresh(getAllRestaurantReviewsProvider(widget.restaurantId, _currentQuery));
          }),
          _buildFilterChip(context, '3 Star', _currentQuery != null && _currentQuery!.rating == 3,
              () {
            setState(() {
              _currentQuery = const GetRestaurantReviewsQuery(rating: 3);
            });
            ref.refresh(getAllRestaurantReviewsProvider(widget.restaurantId, _currentQuery));
          }),
          _buildFilterChip(context, '2 Star', _currentQuery != null && _currentQuery!.rating == 2,
              () {
            setState(() {
              _currentQuery = const GetRestaurantReviewsQuery(rating: 2);
            });
            ref.refresh(getAllRestaurantReviewsProvider(widget.restaurantId, _currentQuery));
          }),
          _buildFilterChip(context, '1 Star', _currentQuery != null && _currentQuery!.rating == 1,
              () {
            setState(() {
              _currentQuery = const GetRestaurantReviewsQuery(rating: 1);
            });
            ref.refresh(getAllRestaurantReviewsProvider(widget.restaurantId, _currentQuery));
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.white,
        selectedColor: AppPallete.primaryColor.withOpacity(0.1),
        checkmarkColor: AppPallete.primaryColor,
        showCheckmark: true,
        avatar: null,
        side: BorderSide(
          color: isSelected ? AppPallete.primaryColor : AppPallete.neutralColor.shade300,
          width: isSelected ? 1.5 : 1,
        ),
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected ? AppPallete.primaryColor : AppPallete.neutralColor.shade700,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildRatingSummary(BuildContext context, double averageRating, int reviewCount) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppPallete.neutralColor.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppPallete.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              averageRating.toStringAsFixed(1),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppPallete.primaryColor,
                  ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < averageRating.floor()
                          ? Icons.star_rounded
                          : (index < averageRating)
                              ? Icons.star_half_rounded
                              : Icons.star_border_rounded,
                      color: AppPallete.primaryColor,
                      size: 24,
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  'Based on $reviewCount ${reviewCount == 1 ? 'review' : 'reviews'}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppPallete.neutralColor.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(BuildContext context, TransactionReview review) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    debugPrint('review: ${review.reviewer.profilePictureUrl}');
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppPallete.neutralColor.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppPallete.neutralColor.withAlpha(128),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: review.reviewer.profilePictureUrl != null
                      ? Image.network(
                          review.reviewer.profilePictureUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppPallete.neutralColor.shade200,
                            child: Icon(
                              Icons.person,
                              color: AppPallete.neutralColor.shade400,
                            ),
                          ),
                        )
                      : Container(
                          color: AppPallete.neutralColor.shade200,
                          child: Icon(
                            Icons.person,
                            color: AppPallete.neutralColor.shade400,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewer.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      dateFormat.format(review.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppPallete.neutralColor.shade500,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppPallete.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${review.rating}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppPallete.neutralColor.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppPallete.neutralColor.shade200,
                width: 1,
              ),
            ),
            child: Text(
              review.review,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class RestaurantReviewsWidget extends ConsumerWidget {
  final String restaurantId;
  final bool showHeader;
  final bool showRatingSummary;

  const RestaurantReviewsWidget({
    super.key,
    required this.restaurantId,
    this.showHeader = true,
    this.showRatingSummary = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        SliverRestaurantReviewsWidget(
          restaurantId: restaurantId,
          showHeader: showHeader,
          showRatingSummary: showRatingSummary,
        ),
      ],
    );
  }
}
