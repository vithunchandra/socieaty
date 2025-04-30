import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:socieaty/core/enums/user_role.enum.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/support-ticket/enum/support_ticket_status_enum.dart';
import 'package:socieaty/features/support-ticket/model/support_ticket.dart';
import 'package:socieaty/features/support-ticket/provider/get_support_tickets_provider.dart';
import 'package:socieaty/features/support-ticket/repository/request/get_support_tickets_request_query.dart';
import 'package:socieaty/features/support-ticket/socket/support_ticket_socket_service.dart';
import 'package:socieaty/features/support-ticket/view/widgets/support_ticket_card.dart';
import 'package:socieaty/shared/models/pagination_query.dart';
import 'package:socieaty/shared/widgets/custom_error_widget.dart';
import 'package:socieaty/shared/widgets/custom_loading_widget.dart';
import 'dart:async';

class CustomerSupportScreen extends ConsumerStatefulWidget {
  const CustomerSupportScreen({super.key});

  @override
  ConsumerState<CustomerSupportScreen> createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends ConsumerState<CustomerSupportScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PagingController<int, SupportTicket> _pagingController = PagingController(firstPageKey: 0);
  final int _pageSize = 10;
  bool _isDisposed = false;

  Timer? _debounce;
  String? _searchQuery;
  SupportTicketStatus? _selectedStatus;
  UserRole? _userRole;

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchTickets(pageKey);
    });

    _searchController.addListener(_onSearchChanged);

    _userRole = ref.read(authLocalRepositoryProvider).getUserData()?.role;

    _initSocketConnection();
  }

  void _initSocketConnection() {
    final socketService = ref.read(supportTicketSocketServiceProvider);

    socketService.initConnection(
      onNewSupportTicketCallback: _handleNewSupportTicket,
      onSupportTicketChangesCallback: _handleSupportTicketChanges,
    );
  }

  void _handleNewSupportTicket(SupportTicket ticket) {
    if (!mounted || _isDisposed) return;

    // Only add the ticket to the list if it matches the current filter
    if (_selectedStatus != null && ticket.status != _selectedStatus) {
      return;
    }

    // Add the new ticket to the beginning of the list
    final updatedItems = List<SupportTicket>.from(_pagingController.itemList ?? []);
    updatedItems.insert(0, ticket);

    _pagingController.itemList = updatedItems;
    setState(() {});
  }

  void _handleSupportTicketChanges(SupportTicket ticket) {
    if (!mounted || _isDisposed) return;

    final currentItems = _pagingController.itemList;
    if (currentItems == null) return;

    // Find if the ticket is in the current list
    final ticketIndex = currentItems.indexWhere((t) => t.id == ticket.id);

    if (ticketIndex >= 0) {
      // If the ticket status changed to closed and we're filtering for open tickets,
      // remove it from the list
      if (ticket.status == SupportTicketStatus.closed &&
          (_selectedStatus == SupportTicketStatus.open || _selectedStatus == null)) {
        final updatedItems = List<SupportTicket>.from(currentItems);
        updatedItems.removeAt(ticketIndex);
        _pagingController.itemList = updatedItems;
      }
      // If the ticket status changed to open and we're filtering for closed tickets,
      // remove it from the list
      else if (ticket.status == SupportTicketStatus.open &&
          _selectedStatus == SupportTicketStatus.closed) {
        final updatedItems = List<SupportTicket>.from(currentItems);
        updatedItems.removeAt(ticketIndex);
        _pagingController.itemList = updatedItems;
      }
      // Otherwise, update the ticket in the list
      else {
        final updatedItems = List<SupportTicket>.from(currentItems);
        updatedItems[ticketIndex] = ticket;
        _pagingController.itemList = updatedItems;
      }
      setState(() {});
    } else if (_shouldAddTicketToList(ticket)) {
      // If the ticket is not in the list but matches the filter, add it
      final updatedItems = List<SupportTicket>.from(currentItems);
      updatedItems.insert(0, ticket);
      _pagingController.itemList = updatedItems;
      setState(() {});
    }
  }

  bool _shouldAddTicketToList(SupportTicket ticket) {
    // Check if the ticket matches the current filter
    if (_selectedStatus != null && ticket.status != _selectedStatus) {
      return false;
    }

    // Check if the search query matches
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      final query = _searchQuery!.toLowerCase();
      if (!ticket.title.toLowerCase().contains(query) &&
          !ticket.description.toLowerCase().contains(query)) {
        return false;
      }
    }

    // Check if the ticket belongs to the current user (if not admin)
    if (_userRole != UserRole.admin) {
      final user = ref.read(authLocalRepositoryProvider).getUserData();
      if (ticket.user.id != user?.id) {
        return false;
      }
    }

    return true;
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = _searchController.text.isEmpty ? null : _searchController.text;
      });
      _pagingController.refresh();
    });
  }

  Future<void> _fetchTickets(int pageKey) async {
    final user = ref.watch(authLocalRepositoryProvider).getUserData();

    if (!mounted || _isDisposed) return;

    try {
      final query = GetSupportTicketsRequestQuery(
        paginationQuery: PaginationQuery(page: pageKey, pageSize: _pageSize),
        userId: user!.role == UserRole.admin ? null : user.id,
        searchQuery: _searchQuery,
        status: _selectedStatus,
      );

      final response = await ref.read(getSupportTicketsProvider(query).future);
      final tickets = response.items;
      final pagination = response.pagination;

      final isLastPage = !pagination.hasNext;

      if (isLastPage) {
        _pagingController.appendLastPage(tickets);
      } else {
        final nextPageKey = pagination.nextPage;
        _pagingController.appendPage(tickets, nextPageKey);
      }
    } catch (error) {
      if (!_isDisposed) {
        _pagingController.error = error;
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _searchQuery = _searchController.text.isEmpty ? null : _searchController.text;
    });
    _pagingController.refresh();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pusat Bantuan',
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_userRole != UserRole.admin)
            IconButton(
              onPressed: () {
                context.push('/customer-support/create');
              },
              icon: const Icon(Icons.support_agent),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilterSection(),
          Expanded(
            child: RefreshIndicator(
              color: AppPallete.primaryColor,
              onRefresh: () async {
                _pagingController.refresh();
                return Future.value();
              },
              child: PagedListView<int, SupportTicket>(
                pagingController: _pagingController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                builderDelegate: PagedChildBuilderDelegate<SupportTicket>(
                  itemBuilder: (context, ticket, index) {
                    return SupportTicketCard(
                      ticket: ticket,
                      onTap: () async {
                        await context.push('/customer-support/${ticket.id}', extra: ticket);
                        // _pagingController.refresh();
                      },
                    );
                  },
                  firstPageProgressIndicatorBuilder: (_) => const CustomLoadingWidget(
                    title: 'Memuat tiket',
                    subtitle: 'Mohon tunggu sementara kami memuat tiket bantuan Anda',
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
                    title: 'Gagal memuat tiket',
                    onPressed: () => _pagingController.retryLastFailedRequest(),
                    error: _pagingController.error.toString(),
                  ),
                  newPageErrorIndicatorBuilder: (context) => CustomErrorWidget(
                    title: 'Gagal memuat tiket',
                    onPressed: () => _pagingController.retryLastFailedRequest(),
                    error: _pagingController.error.toString(),
                  ),
                  noItemsFoundIndicatorBuilder: (context) => _buildEmptyState(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
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
              hintText: 'Cari tiket atau filter berdasarkan status',
              prefixIcon: Icon(
                Icons.search,
                color: AppPallete.neutralColor.shade500,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: AppPallete.neutralColor.shade500,
                      ),
                      onPressed: () {
                        _searchController.clear();
                      },
                    ),
                  IconButton(
                    icon: Icon(
                      Icons.filter_list,
                      color: AppPallete.neutralColor.shade500,
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => _buildStatusFilterSheet(),
                      );
                    },
                  ),
                ],
              ),
              filled: true,
              fillColor: AppPallete.neutralColor.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilterSheet() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Filter berdasarkan Status',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Semua'),
                selected: _selectedStatus == null,
                onSelected: (selected) {
                  setState(() {
                    _selectedStatus = null;
                  });
                  _pagingController.refresh();
                  Navigator.pop(context);
                },
              ),
              FilterChip(
                label: const Text('Terbuka'),
                selected: _selectedStatus == SupportTicketStatus.open,
                onSelected: (selected) {
                  setState(() {
                    _selectedStatus = SupportTicketStatus.open;
                  });
                  _pagingController.refresh();
                  Navigator.pop(context);
                },
              ),
              FilterChip(
                label: const Text('Ditutup'),
                selected: _selectedStatus == SupportTicketStatus.closed,
                onSelected: (selected) {
                  setState(() {
                    _selectedStatus = SupportTicketStatus.closed;
                  });
                  _pagingController.refresh();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.support_agent,
              size: 64,
              color: AppPallete.neutralColor.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              'Tidak Ada Tiket Bantuan',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppPallete.neutralColor.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery != null || _selectedStatus != null
                  ? 'Tidak ada tiket yang cocok dengan filter Anda. Coba ubah kriteria pencarian atau filter.'
                  : 'Anda belum membuat tiket bantuan apa pun.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: AppPallete.neutralColor.shade600,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
