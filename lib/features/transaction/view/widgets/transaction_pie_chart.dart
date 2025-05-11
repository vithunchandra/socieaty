import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/transaction/model/transaction_insight.dart';

class TransactionPieChart extends StatelessWidget {
  const TransactionPieChart({
    super.key,
    required this.data,
  });

  final TransactionInsight data;

  @override
  Widget build(BuildContext context) {
    final totalTransactions = data.totalFoodOrderTransactions + data.totalReservationTransactions;
    final bool hasData = totalTransactions > 0;

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: hasData
              ? _buildPieChart(context, totalTransactions)
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.pie_chart_outline,
                        size: 48,
                        color: AppPallete.neutralColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada data transaksi',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppPallete.neutralColor.shade500,
                            ),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(
              context,
              'Pesanan Makanan',
              AppPallete.secondaryColor,
              hasData ? data.totalFoodOrderTransactions.toString() : '0',
            ),
            const SizedBox(width: 24),
            _buildLegendItem(
              context,
              'Reservasi',
              AppPallete.infoColor,
              hasData ? data.totalReservationTransactions.toString() : '0',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(
              context,
              'Sukses',
              hasData ? data.totalSuccessTransactions.toString() : '0',
              Icons.check_circle,
              AppPallete.successColor,
            ),
            _buildStatItem(
              context,
              'Gagal',
              hasData ? data.totalFailedTransactions.toString() : '0',
              Icons.cancel,
              AppPallete.errorColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPieChart(BuildContext context, int totalTransactions) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            color: AppPallete.secondaryColor,
            value: data.totalFoodOrderTransactions.toDouble(),
            title:
                '${((data.totalFoodOrderTransactions / totalTransactions) * 100).toStringAsFixed(0)}%',
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: AppPallete.infoColor,
            value: data.totalReservationTransactions.toDouble(),
            title:
                '${((data.totalReservationTransactions / totalTransactions) * 100).toStringAsFixed(0)}%',
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        startDegreeOffset: 180,
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String title, Color color, String value) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(
      BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
