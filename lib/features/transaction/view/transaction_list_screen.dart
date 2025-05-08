import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:socieaty/core/enums/sort_order_enum.dart';
import 'package:socieaty/core/enums/transaction.enum.dart';
import 'package:socieaty/core/enums/user_role.enum.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/transaction/model/transaction_data.dart';
import 'package:socieaty/features/transaction/provider/paginate_transactions_provider.dart';
import 'package:socieaty/features/transaction/repository/request/paginate_transactions_request_query.dart';
import 'package:socieaty/features/transaction/view/widgets/transaction_card_widget.dart';
import 'package:socieaty/features/transaction/view/widgets/transaction_filter_bottom_sheet.dart';
import 'package:socieaty/shared/models/pagination_query.dart';
import 'package:socieaty/shared/widgets/custom_empty_widget.dart';
import 'package:socieaty/shared/widgets/custom_error_widget.dart';
import 'package:socieaty/shared/widgets/custom_loading_widget.dart';

class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key});

  @override
  ConsumerState<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends ConsumerState<TransactionListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PagingController<int, TransactionData> _pagingController =
      PagingController(firstPageKey: 0);
  final int _pageSize = 10;
  bool _isDisposed = false;
  Timer? _debounce;
  late PaginateTransactionsRequestQuery _requestQuery;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authLocalRepositoryProvider).getUserData();

    _pagingController.addPageRequestListener((pageKey) {
      _fetchTransactions(pageKey);
    });

    _searchController.addListener(_onSearchChanged);

    final restaurantId = user?.role == UserRole.admin || user?.role == UserRole.customer ? null : user?.restaurantData?.id;
    final customerId = user?.role == UserRole.admin || user?.role == UserRole.restaurant ? null : user?.customerData?.id;
    _requestQuery = PaginateTransactionsRequestQuery(
      paginationQuery: PaginationQuery(page: 0, pageSize: _pageSize),
      restaurantId: restaurantId,
      customerId: customerId,
    );
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _requestQuery = _requestQuery.copyWith(
          searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
        );
      });
      _pagingController.refresh();
    });
  }

  Future<void> _fetchTransactions(int pageKey) async {
    if (!mounted || _isDisposed) return;

    try {
      final query = _requestQuery.copyWith(
        paginationQuery: PaginationQuery(page: pageKey, pageSize: _pageSize),
      );

      final response = await paginateTransactions(ref, query);
      final transactions = response.items;

      final isLastPage = transactions.length < _pageSize;

      if (isLastPage) {
        _pagingController.appendLastPage(transactions);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(transactions, nextPageKey);
      }
    } catch (error) {
      if (!_isDisposed) {
        _pagingController.error = error;
      }
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionFilterBottomSheet(
        rangeStartDate: _requestQuery.rangeStartDate,
        rangeEndDate: _requestQuery.rangeEndDate,
        sortOrder: _requestQuery.sortOrder,
        sortDirection: _requestQuery.sortDirection,
        onApplyFilter: (
          DateTime? startDate,
          DateTime? endDate,
          TransactionSortBy? sortBy,
          SortOrder? sortDirection,
        ) {
          setState(() {
            _requestQuery = _requestQuery.copyWith(
              rangeStartDate: startDate,
              rangeEndDate: endDate,
              sortOrder: sortBy,
              sortDirection: sortDirection,
            );
          });
          _pagingController.refresh();
        },
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _searchController.dispose();
    _pagingController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transactions',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchAndFilterSection(textTheme),
          Expanded(
            child: RefreshIndicator(
              color: AppPallete.primaryColor,
              onRefresh: () async {
                _pagingController.refresh();
                return Future.value();
              },
              child: PagedListView<int, TransactionData>(
                pagingController: _pagingController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                builderDelegate: PagedChildBuilderDelegate<TransactionData>(
                  itemBuilder: (context, transaction, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TransactionCardWidget(
                        transaction: transaction,
                      ),
                    );
                  },
                  firstPageProgressIndicatorBuilder: (_) => const CustomLoadingWidget(
                    title: 'Loading transactions',
                    subtitle: 'Please wait while we load the transactions',
                  ),
                  newPageProgressIndicatorBuilder: (_) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppPallete.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  firstPageErrorIndicatorBuilder: (context) => CustomErrorWidget(
                    title: 'Error loading transactions',
                    onPressed: () => _pagingController.retryLastFailedRequest(),
                    error: _pagingController.error.toString(),
                  ),
                  newPageErrorIndicatorBuilder: (context) => CustomErrorWidget(
                    title: 'Error loading transactions',
                    onPressed: () => _pagingController.retryLastFailedRequest(),
                    error: _pagingController.error.toString(),
                  ),
                  noItemsFoundIndicatorBuilder: (context) => CustomEmptyWidget(
                    icon: Icons.receipt_long_outlined,
                    title: 'No Transactions Found',
                    description:
                        'No transactions match your current filters. Try changing your search or filter criteria.',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterSection(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppPallete.neutralColor.shade200.withAlpha(120),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by restaurant name, etc',
              prefixIcon: Icon(
                Icons.search,
                color: AppPallete.neutralColor.shade500,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: AppPallete.neutralColor.shade500,
                      ),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppPallete.neutralColor.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppPallete.neutralColor.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButton2<TransactionServiceType?>(
                    value: _requestQuery.serviceType,
                    hint: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        'Service Type',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppPallete.neutralColor.shade500,
                        ),
                      ),
                    ),
                    iconStyleData: IconStyleData(
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: AppPallete.neutralColor.shade700,
                      ),
                    ),
                    isExpanded: true,
                    underline: const SizedBox(),
                    buttonStyleData: const ButtonStyleData(
                      padding: EdgeInsets.only(left: 16, right: 8),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      offset: const Offset(0, -5),
                    ),
                    items: [
                      DropdownMenuItem<TransactionServiceType?>(
                        value: null,
                        child: Text(
                          'All Types',
                          style: textTheme.bodyMedium,
                        ),
                      ),
                      ...TransactionServiceType.values.map((type) {
                        final displayName =
                            type == TransactionServiceType.foodOrder ? 'Food Order' : 'Reservation';
                        return DropdownMenuItem<TransactionServiceType?>(
                          value: type,
                          child: Text(
                            displayName,
                            style: textTheme.bodyMedium,
                          ),
                        );
                      }),
                    ],
                    onChanged: (TransactionServiceType? value) {
                      setState(() {
                        _requestQuery = _requestQuery.copyWith(serviceType: value);
                      });
                      _pagingController.refresh();
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _showFilterBottomSheet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPallete.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(
                  Icons.filter_list,
                  size: 18,
                  color: Colors.white,
                ),
                label: Text(
                  'Filters',
                  style: textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (_hasActiveFilters())
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Text(
                    'Active filters:',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppPallete.neutralColor.shade600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _buildActiveFilterChips(textTheme),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return _requestQuery.customerId != null ||
        _requestQuery.restaurantId != null ||
        _requestQuery.rangeStartDate != null ||
        _requestQuery.rangeEndDate != null ||
        _requestQuery.sortOrder != null;
  }

  List<Widget> _buildActiveFilterChips(TextTheme textTheme) {
    final List<Widget> chips = [];

    if (_requestQuery.rangeStartDate != null && _requestQuery.rangeEndDate != null) {
      final dateFormat = DateFormat('MMM d, y');
      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Chip(
            backgroundColor: AppPallete.primaryColor.shade50,
            label: Text(
              '${dateFormat.format(_requestQuery.rangeStartDate!)} - ${dateFormat.format(_requestQuery.rangeEndDate!)}',
              style: textTheme.bodySmall?.copyWith(
                color: AppPallete.primaryColor.shade700,
              ),
            ),
            deleteIcon: Icon(
              Icons.close,
              size: 16,
              color: AppPallete.primaryColor.shade700,
            ),
            onDeleted: () {
              setState(() {
                _requestQuery = _requestQuery.copyWith(
                  rangeStartDate: null,
                  rangeEndDate: null,
                );
              });
              _pagingController.refresh();
            },
          ),
        ),
      );
    }

    if (_requestQuery.sortOrder != null) {
      final sortName = _requestQuery.sortOrder!.name[0].toUpperCase() +
          _requestQuery.sortOrder!.name.substring(1);
      final direction = _requestQuery.sortDirection == SortOrder.desc ? 'Desc' : 'Asc';
      chips.add(
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Chip(
            backgroundColor: AppPallete.primaryColor.shade50,
            label: Text(
              'Sort: $sortName ($direction)',
              style: textTheme.bodySmall?.copyWith(
                color: AppPallete.primaryColor.shade700,
              ),
            ),
            deleteIcon: Icon(
              Icons.close,
              size: 16,
              color: AppPallete.primaryColor.shade700,
            ),
            onDeleted: () {
              setState(() {
                _requestQuery = _requestQuery.copyWith(
                  sortOrder: null,
                  sortDirection: null,
                );
              });
              _pagingController.refresh();
            },
          ),
        ),
      );
    }

    return chips;
  }
}
