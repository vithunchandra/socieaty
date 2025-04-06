import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/topup/viewmodel/topup_bottom_sheet_view_model.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class TopupBottomSheet extends ConsumerStatefulWidget {
  const TopupBottomSheet({super.key});

  @override
  ConsumerState<TopupBottomSheet> createState() => _TopupBottomSheetState();
}

class _TopupBottomSheetState extends ConsumerState<TopupBottomSheet> {
  final TextEditingController _amountController = TextEditingController();
  final List<int> _quickAmounts = [50000, 100000, 200000, 500000];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  _createTopup() {
    if (_amountController.text.isEmpty) {
      showSnackbar(context, "Jumlah topup tidak boleh kosong");
      return;
    }
    ref
        .read(topupBottomSheetViewModelProvider.notifier)
        .createTopup(double.parse(_amountController.text));
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(topupBottomSheetViewModelProvider).createdTopup is LoadingState;

    ref.listen(topupBottomSheetViewModelProvider, (previous, next) {
      switch (next.createdTopup) {
        case SuccessState(data: final data):
          debugPrint(data.toString());
          context.push('/customer/profile/wallet/topup', extra: data.topup.id);
          context.pop();
        case ErrorState(message: final message):
          showSnackbar(context, message);
        case LoadingState():
        case IdleState():
      }
    });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Up Wallet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                color: AppPallete.neutralColor.shade700,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Enter Amount',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Rp',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppPallete.neutralColor.shade700,
                      ),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              hintText: '0',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppPallete.neutralColor.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppPallete.neutralColor.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppPallete.primaryColor),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Quick Amount',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickAmounts.map((amount) {
              return GestureDetector(
                onTap: () {
                  _amountController.text = amount.toString();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppPallete.neutralColor.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppPallete.neutralColor.shade300),
                  ),
                  child: Text(
                    'Rp $amount',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _createTopup();
              },
              style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
                  ),
              child: isLoading
                  ? const LoadingIndicatorWidget(
                      size: 24,
                      color: Colors.white,
                    )
                  : Text(
                      'Next',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
