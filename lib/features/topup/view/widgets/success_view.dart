import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/topup/model/topup.dart';

class TopupSuccessView extends StatelessWidget {
  final Topup topup;

  const TopupSuccessView({
    super.key,
    required this.topup,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize the locale data for Indonesian
    initializeDateFormatting('id');

    final currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    final dateFormatter = DateFormat('dd MMMM yyyy, HH:mm', 'id');
    final settledDate = topup.settlemantTime ?? topup.createdAt;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 72,
            color: AppPallete.successColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Pembayaran Berhasil',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppPallete.neutralColor.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Topup ${currencyFormatter.format(topup.amount)} telah berhasil ditambahkan ke dompet Anda',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppPallete.neutralColor.shade600,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppPallete.neutralColor.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppPallete.neutralColor.shade200),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rincian Transaksi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppPallete.neutralColor.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTransactionDetail('ID Transaksi', topup.id.substring(0, 8).toUpperCase()),
                _buildTransactionDetail('Jumlah', currencyFormatter.format(topup.amount)),
                _buildTransactionDetail('Metode Pembayaran', topup.paymentMethod ?? 'Unknown'),
                _buildTransactionDetail('Waktu Transaksi', dateFormatter.format(settledDate)),
                if (topup.transactionId != null)
                  _buildTransactionDetail('ID Pembayaran', topup.transactionId!),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallete.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text(
              'Kembali ke Dompet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppPallete.neutralColor.shade600,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppPallete.neutralColor.shade800,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
