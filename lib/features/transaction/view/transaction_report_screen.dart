import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:socieaty/core/enums/time_scale.dart';
import 'package:socieaty/core/enums/user_role.enum.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/transaction/provider/get_transaction_chart_data_provider.dart';
import 'package:socieaty/features/transaction/provider/get_transaction_insight_data_provider.dart';
import 'package:socieaty/features/transaction/repository/request/get-transactions-chart-data-request-query.dart';
import 'package:socieaty/features/transaction/repository/request/get-transactions-insight-request-query.dart';
import 'package:socieaty/features/transaction/view/widgets/date_range_picker_bottom_sheet.dart';
import 'package:socieaty/features/transaction/view/widgets/empty_chart_state.dart';
import 'package:socieaty/features/transaction/view/widgets/transaction_line_chart.dart';
import 'package:socieaty/features/transaction/view/widgets/transaction_pie_chart.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';
import 'package:socieaty/shared/widgets/custom_loading_widget.dart';

class TransactionReportScreen extends ConsumerStatefulWidget {
  const TransactionReportScreen({
    super.key,
  });

  @override
  ConsumerState<TransactionReportScreen> createState() => _TransactionReportScreenState();
}

class _TransactionReportScreenState extends ConsumerState<TransactionReportScreen> {
  late GetTransactionsInsightRequestQuery insightRequestQuery;
  late GetTransactionsChartDataRequestQuery chartRequestQuery;
  late SocieatyUser? user;

  TimeScale selectedTimeScale = TimeScale.week;

  // Separate date ranges for each chart
  late DateTime insightStartDate;
  late DateTime insightEndDate;
  late DateTime chartStartDate;
  late DateTime chartEndDate;

  @override
  void initState() {
    super.initState();

    // Default time range - last 7 days for both charts
    final now = DateTime.now();

    // Initialize insight chart date range
    insightEndDate = now;
    insightStartDate = now.subtract(const Duration(days: 7));

    // Initialize line chart date range
    chartEndDate = now;
    chartStartDate = now.subtract(const Duration(days: 30));

    user = ref.read(authLocalRepositoryProvider).getUserData();

    final restaurantId = user?.role == UserRole.admin || user?.role == UserRole.customer
        ? null
        : user?.restaurantData?.id;
    // final customerId = user?.role == UserRole.admin || user?.role == UserRole.restaurant ? null : user?.customerData?.id;

    insightRequestQuery = GetTransactionsInsightRequestQuery(
      restaurantId: restaurantId,
      rangeStartDate: insightStartDate,
      rangeEndDate: insightEndDate,
    );

    chartRequestQuery = GetTransactionsChartDataRequestQuery(
      restaurantId: restaurantId,
      timeScale: selectedTimeScale,
      rangeStartDate: chartStartDate,
      rangeEndDate: chartEndDate,
    );
  }

  void updateTimeScale(TimeScale newTimeScale) {
    setState(() {
      selectedTimeScale = newTimeScale;

      // Update the chart request query with new time scale
      chartRequestQuery = GetTransactionsChartDataRequestQuery(
        restaurantId: user?.role == UserRole.restaurant ? user?.restaurantData?.id : null,
        timeScale: newTimeScale,
        rangeStartDate: chartStartDate,
        rangeEndDate: chartEndDate,
      );
    });

    // Invalidate the chart data provider to refresh data
    ref.invalidate(getTransactionChartDataProvider(chartRequestQuery));
  }

  void updateInsightDateRange(DateTime newStartDate, DateTime newEndDate) {
    setState(() {
      insightStartDate = newStartDate;
      insightEndDate = newEndDate;

      // Update insight request query with new date range
      insightRequestQuery = GetTransactionsInsightRequestQuery(
        restaurantId: user?.role == UserRole.restaurant ? user?.restaurantData?.id : null,
        rangeStartDate: insightStartDate,
        rangeEndDate: insightEndDate,
      );
    });

    // Invalidate insight provider to refresh data
    ref.invalidate(getTransactionInsightProvider(insightRequestQuery));
  }

  void updateChartDateRange(DateTime newStartDate, DateTime newEndDate) {
    setState(() {
      chartStartDate = newStartDate;
      chartEndDate = newEndDate;

      // Update chart request query with new date range
      chartRequestQuery = GetTransactionsChartDataRequestQuery(
        restaurantId: user?.role == UserRole.restaurant ? user?.restaurantData?.id : null,
        timeScale: selectedTimeScale,
        rangeStartDate: chartStartDate,
        rangeEndDate: chartEndDate,
      );
    });

    // Invalidate chart data provider to refresh data
    ref.invalidate(getTransactionChartDataProvider(chartRequestQuery));
  }

  void _showInsightDateRangePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DateRangePickerBottomSheet(
          initialStartDate: insightStartDate,
          initialEndDate: insightEndDate,
          onDateRangeSelected: (newStartDate, newEndDate) {
            updateInsightDateRange(newStartDate, newEndDate);
          },
        ),
      ),
    );
  }

  void _showChartDateRangePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DateRangePickerBottomSheet(
          initialStartDate: chartStartDate,
          initialEndDate: chartEndDate,
          onDateRangeSelected: (newStartDate, newEndDate) {
            updateChartDateRange(newStartDate, newEndDate);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.neutralColor.shade50,
      appBar: AppBar(
        title: Text(
          'Transaction Report',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        backgroundColor: AppPallete.neutralColor.shade50,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(context),
              const SizedBox(height: 24),
              _buildInsightSection(context),
              const SizedBox(height: 24),
              _buildTimeScaleSelector(),
              const SizedBox(height: 16),
              _buildChartSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    final insightData = ref.watch(getTransactionInsightProvider(insightRequestQuery));

    return insightData.when(
      data: (data) {
        return GestureDetector(
          onTap: () {
            context.push('/admin/transaction-report/history');
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppPallete.primaryColor,
                  AppPallete.primaryColor.shade400,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppPallete.primaryColor.withAlpha(50),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.show_chart,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Income Summary',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  formatter.format(data.totalIncome),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total Transactions: ${data.totalSuccessTransactions + data.totalFailedTransactions}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withAlpha(220),
                      ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    Text(
                      "Click to see the report",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withAlpha(220),
                          ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.touch_app,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(
            color: AppPallete.primaryColor,
          ),
        ),
      ),
      error: (error, stack) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppPallete.errorColor.withAlpha(50),
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color: AppPallete.errorColor,
              size: 24,
            ),
            const SizedBox(height: 12),
            Text(
              'Failed to load income data',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppPallete.neutralColor.shade600,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightSection(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final insightData = ref.watch(getTransactionInsightProvider(insightRequestQuery));

        return insightData.when(
          data: (data) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transaction Distribution',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _showInsightDateRangePicker,
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppPallete.neutralColor.shade300.withAlpha(30),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.date_range,
                          color: AppPallete.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${DateFormat('MMM dd, yyyy').format(insightStartDate)} - ${DateFormat('MMM dd, yyyy').format(insightEndDate)}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: AppPallete.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
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
                  child: TransactionPieChart(data: data),
                ),
              ],
            );
          },
          loading: () => const SizedBox(
            height: 300,
            child: Center(
              child: CircularProgressIndicator(
                color: AppPallete.primaryColor,
              ),
            ),
          ),
          error: (error, stack) => const CustomLoadingWidget(
            title: 'Error Loading Insight Data',
            subtitle:
                'There was an error loading the transaction insight data. Please try again later.',
          ),
        );
      },
    );
  }

  Widget _buildTimeScaleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Income Trend',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppPallete.neutralColor.shade200,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<TimeScale>(
                    value: selectedTimeScale,
                    buttonStyleData: const ButtonStyleData(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      height: 36,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: TimeScale.day,
                        child: Text('Daily'),
                      ),
                      DropdownMenuItem(
                        value: TimeScale.week,
                        child: Text('Weekly'),
                      ),
                      DropdownMenuItem(
                        value: TimeScale.month,
                        child: Text('Monthly'),
                      ),
                    ],
                    onChanged: (TimeScale? newValue) {
                      if (newValue != null) {
                        updateTimeScale(newValue);
                      }
                    },
                    dropdownStyleData: DropdownStyleData(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      offset: const Offset(0, 8),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: _showChartDateRangePicker,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppPallete.primaryColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.date_range,
                        color: AppPallete.primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${DateFormat('MMM d').format(chartStartDate)} - ${DateFormat('MMM d').format(chartEndDate)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartSection(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final chartData = ref.watch(getTransactionChartDataProvider(chartRequestQuery));

        return chartData.when(
          data: (data) {
            if (data.isEmpty) {
              return EmptyChartState(
                onRefresh: () => ref.invalidate(getTransactionChartDataProvider(chartRequestQuery)),
              );
            }

            return Container(
              padding: const EdgeInsets.all(16),
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
              child: TransactionLineChart(
                data: data,
                timeScale: selectedTimeScale,
              ),
            );
          },
          loading: () => const SizedBox(
            height: 300,
            child: Center(
              child: CircularProgressIndicator(
                color: AppPallete.primaryColor,
              ),
            ),
          ),
          error: (error, stack) => Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppPallete.errorColor.withAlpha(50),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppPallete.errorColor,
                  size: 24,
                ),
                const SizedBox(height: 12),
                Text(
                  'Failed to load chart data',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppPallete.neutralColor.shade600,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
