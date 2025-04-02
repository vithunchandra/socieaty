import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/food-order/model/food_order_transaction.dart';
import 'package:socieaty/features/transaction_review/model/transaction_review.dart';
import 'package:socieaty/features/transaction_review/view/widgets/rating_star.dart';
import 'package:socieaty/features/transaction_review/viewmodel/restaurant_rating_screen_view_model.dart';
import 'package:socieaty/features/transaction_review/viewstate/create_transaction_review_form_state.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/image_error_widget.dart';
import 'package:socieaty/shared/widgets/image_loading_widget.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class RestaurantRatingScreen extends ConsumerStatefulWidget {
  final FoodOrderTransaction transaction;

  const RestaurantRatingScreen({
    super.key,
    required this.transaction,
  });

  @override
  ConsumerState<RestaurantRatingScreen> createState() => _RestaurantRatingScreenState();
}

class _RestaurantRatingScreenState extends ConsumerState<RestaurantRatingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  int _selectedRating = 5;
  final _formKey = GlobalKey<FormState>();
  CreateTransactionReviewFormState _formData = CreateTransactionReviewFormState(
    transactionId: '',
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    );

    _animationController.forward();
    _formData = _formData.copyWith(transactionId: widget.transaction.transactionId);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = ref.watch(
        restaurantRatingScreenViewModelProvider(widget.transaction.transactionId)
            .select((state) => state.createReviewState is LoadingState));
    ref.listen(restaurantRatingScreenViewModelProvider(widget.transaction.transactionId),
        (previous, next) {
      switch (next.createReviewState) {
        case SuccessState<TransactionReview>():
          showSnackbar(context, 'Review submitted successfully');
          context.pop();
        case ErrorState(message: final message):
          showSnackbar(context, message, state: SnackbarState.error);
        case LoadingState<TransactionReview>():
        case IdleState():
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rate Restaurant',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppPallete.primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.2),
                      end: Offset.zero,
                    ).animate(_slideAnimation),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: restaurantHeader(context),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.2),
                      end: Offset.zero,
                    ).animate(_slideAnimation),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          const Text(
                            'How was your experience?',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          buildRatingStars(),
                          const SizedBox(height: 32),
                          buildReviewTextField(),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : () => submitReview(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppPallete.primaryColor,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: AppPallete.primaryColor.withAlpha(100),
                                elevation: 2,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: LoadingIndicatorWidget(size: 20, color: Colors.white),
                                    )
                                  : const Text(
                                      'Submit Review',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget restaurantHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(40),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: widget.transaction.restaurant.restaurantData.restaurantBannerUrl,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => imageErrorWidget(context, error, null),
              progressIndicatorBuilder: (context, url, progress) =>
                  imageLoadingWidget(context, url, progress),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.transaction.restaurant.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Order #${widget.transaction.orderId.substring(0, 6)}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppPallete.neutralColor.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildRatingStars() {
    // Calculate responsive star size based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final responsivePadding = screenWidth < 360 ? 4.0 : 8.0;
    final starSize = screenWidth < 360 ? 32.0 : 36.0;

    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        width: constraints.maxWidth,
        alignment: Alignment.center,
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: responsivePadding,
          runSpacing: 10,
          children: List.generate(5, (index) {
            return RatingStar(
              isSelected: index < _selectedRating,
              onTap: () {
                setState(() {
                  _selectedRating = index + 1;
                });
              },
              size: starSize,
            );
          }),
        ),
      );
    });
  }

  Widget buildReviewTextField() {
    return TextFormField(
      maxLines: 5,
      maxLength: 200,
      decoration: InputDecoration(
        hintText: 'Share your experience with this restaurant...',
        fillColor: Colors.grey.withAlpha(20),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your review';
        }
        if (value.length < 10) {
          return 'Review should be at least 10 characters';
        }
        return null;
      },
      onSaved: (value) {
        _formData = _formData.copyWith(review: value ?? '');
      },
    );
  }

  Future<void> submitReview() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _formData = _formData.copyWith(rating: _selectedRating);
      ref
          .read(restaurantRatingScreenViewModelProvider(widget.transaction.transactionId).notifier)
          .createReview(_formData);
    }
  }
}
