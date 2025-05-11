import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';

class EmptyChartState extends StatelessWidget {
  const EmptyChartState({
    super.key,
    required this.onRefresh,
  });

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            Icons.show_chart,
            size: 48,
            color: AppPallete.neutralColor.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada data chart',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppPallete.neutralColor.shade700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tidak ada data transaksi untuk rentang waktu yang dipilih',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppPallete.neutralColor.shade600,
                ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRefresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallete.primaryColor,
            ),
            child: const Text(
              'Muat Ulang',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
