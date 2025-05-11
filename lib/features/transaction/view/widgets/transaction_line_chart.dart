import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:socieaty/core/enums/time_scale.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/transaction/model/transaction_chart.dart';

class TransactionLineChart extends StatefulWidget {
  const TransactionLineChart({
    super.key,
    required this.data,
    required this.timeScale,
  });

  final List<TransactionChart> data;
  final TimeScale timeScale;

  @override
  State<TransactionLineChart> createState() => _TransactionLineChartState();
}

class _TransactionLineChartState extends State<TransactionLineChart> {
  late TransformationController _transformationController;
  late double _minX;
  late double _maxX;
  late double _minY;
  late double _maxY;
  final bool _isPanEnabled = true;
  final bool _isScaleEnabled = true;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _initializeRanges();
  }

  @override
  void didUpdateWidget(TransactionLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _initializeRanges();
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _initializeRanges() {
    if (widget.data.isEmpty) {
      _minX = 0;
      _maxX = 1;
      _minY = 0;
      _maxY = 100;
    } else {
      _minX = 0;
      _maxX = (widget.data.length - 1).toDouble();
      _minY = 0;
      _maxY = _findMaxYValue(widget.data);
    }
  }

  void _resetZoom() {
    setState(() {
      _transformationController.value = Matrix4.identity();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasData = widget.data.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Riwayat Transaksi',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            IconButton(
              icon: const Icon(
                Icons.refresh,
                size: 20,
                color: AppPallete.primaryColor,
              ),
              onPressed: hasData ? _resetZoom : null,
              tooltip: 'Reset zoom',
            ),
          ],
        ),
        SizedBox(
          height: 250,
          width: double.infinity,
          child: hasData
              ? _buildChart()
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.bar_chart_outlined,
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
        if (hasData) ...[
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Gunakan gesture untuk zoom dan menggeser',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppPallete.neutralColor.shade500,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildChartLegendItem(
              context,
              'Income',
              AppPallete.primaryColor,
            ),
            const SizedBox(width: 24),
            _buildChartLegendItem(
              context,
              'Transactions',
              AppPallete.infoColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChart() {
    return LineChart(
      transformationConfig: FlTransformationConfig(
        scaleAxis: FlScaleAxis.horizontal,
        minScale: 1.0,
        maxScale: 10.0,
        panEnabled: _isPanEnabled,
        scaleEnabled: _isScaleEnabled,
        transformationController: _transformationController,
      ),
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppPallete.neutralColor.shade200,
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              maxIncluded: true,
              minIncluded: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= widget.data.length) {
                  return const SizedBox.shrink();
                }

                final title = widget.data[index].title;

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppPallete.neutralColor.shade600,
                        ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                final formatter = NumberFormat.compact();

                if (value <= 0) {
                  return const SizedBox.shrink();
                }

                return Text(
                  formatter.format(value),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppPallete.neutralColor.shade600,
                      ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        minX: _minX,
        maxX: _maxX,
        minY: _minY,
        maxY: _maxY,
        lineBarsData: [
          _createIncomeLineData(widget.data),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppPallete.neutralColor.shade700.withAlpha(220),
            tooltipRoundedRadius: 8,
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final index = touchedSpot.x.toInt();
                if (index < 0 || index >= widget.data.length) {
                  return null;
                }

                return LineTooltipItem(
                  'Income: ${NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0).format(touchedSpot.y)}',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: '\nDate: ${DateFormat('dd MMM yyyy').format(widget.data[index].date)}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.normal, fontSize: 12),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
      ),
      duration: Duration.zero,
    );
  }

  Widget _buildChartLegendItem(BuildContext context, String title, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  LineChartBarData _createIncomeLineData(List<TransactionChart> data) {
    List<FlSpot> spots = [];

    if (data.isEmpty) {
      return LineChartBarData(spots: []);
    }

    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i].totalIncome));
    }

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: AppPallete.primaryColor,
      barWidth: 3,
      isStrokeCapRound: true,
      preventCurveOverShooting: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 3,
            color: AppPallete.primaryColor,
            strokeWidth: 1,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        color: AppPallete.primaryColor.withAlpha(40),
      ),
    );
  }

  double _findMaxYValue(List<TransactionChart> data) {
    if (data.isEmpty) return 100;
    double maxIncome = data.map((e) => e.totalIncome).reduce((a, b) => a > b ? a : b);
    return maxIncome * 1.2;
  }

  double _calculateYAxisInterval(List<TransactionChart> data) {
    if (data.isEmpty) return 20;
    double maxIncome = data.map((e) => e.totalIncome).reduce((a, b) => a > b ? a : b);

    if (maxIncome <= 1000) return 200;
    if (maxIncome <= 10000) return 2000;
    if (maxIncome <= 100000) return 20000;
    if (maxIncome <= 1000000) return 200000;

    return 1000000;
  }
}
