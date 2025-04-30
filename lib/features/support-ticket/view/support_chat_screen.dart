import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/support-ticket/enum/support_ticket_status_enum.dart';
import 'package:socieaty/features/support-ticket/model/support_ticket.dart';
import 'package:socieaty/features/support-ticket/model/support_ticket_message.dart';
import 'package:socieaty/features/support-ticket/provider/track_support_ticket_message_provider.dart';
import 'package:socieaty/features/support-ticket/socket/support_chat_socket_service.dart';
import 'package:socieaty/features/support-ticket/viewmodel/support_chat_view_model.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/custom_error_widget.dart';
import 'package:socieaty/shared/widgets/custom_loading_widget.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';
import 'package:socieaty/shared/widgets/profile_picture_widget.dart';
import 'package:intl/intl.dart';

class SupportChatScreen extends ConsumerStatefulWidget {
  final SupportTicket ticket;

  const SupportChatScreen({
    super.key,
    required this.ticket,
  });

  @override
  ConsumerState<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends ConsumerState<SupportChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late SupportChatSocketService _supportChatSocketService;
  SocieatyUser? _currentUser;
  late SupportTicket _ticket;

  List<SupportTicketMessage> _messages = List.empty(growable: true);
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _socketConnected = false;
  bool _isTicketInfoExpanded = true;

  @override
  void initState() {
    super.initState();

    _ticket = widget.ticket;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeSocketService();
    });
    _currentUser = ref.read(authLocalRepositoryProvider).getUserData();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _supportChatSocketService.disconnect();
    super.dispose();
  }

  void initializeSocketService() {
    _supportChatSocketService = ref.read(supportChatSocketServiceProvider);

    debugPrint('Initializing socket service');
    _supportChatSocketService.initConnection(
      onNewSupportChatMessage: (data) {
        final message = SupportTicketMessage.fromJson(data);
        if (message.supportTicketId == _ticket.id) {
          if (mounted) {
            setState(() {
              _messages.add(message);
            });

            _scrollToBottom();
          }
        }
      },
      onConnected: () {
        if (mounted) {
          setState(() {
            _socketConnected = true;
          });

          _loadMessages();
        }
      },
    );
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final result = await ref.read(trackSupportTicketMessageProvider(_ticket.id).future);
      _messages = List<SupportTicketMessage>.from(result);
    } catch (error) {
      setState(() {
        _hasError = true;
        _errorMessage = error.toString();
      });
      showSnackbar(null, error.toString(), state: SnackbarState.error);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    ref
        .read(supportChatViewModelProvider(_ticket.id).notifier)
        .createMessage(_messageController.text);
    _messageController.clear();
  }

  void _retryLoadMessages() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    if (_socketConnected) {
      _loadMessages();
    } else {
      initializeSocketService();
    }
  }

  void _closeTicket() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tutup Tiket'),
        content: const Text(
            'Apakah Anda yakin ingin menutup tiket dukungan ini? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            child: Text(
              'Batal',
              style: TextStyle(color: AppPallete.neutralColor.shade700),
            ),
            onPressed: () => context.pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallete.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Tutup Tiket'),
            onPressed: () {
              // Placeholder for close ticket logic
              context.pop();
              ref.read(supportChatViewModelProvider(_ticket.id).notifier).updateTicket(
                    SupportTicketStatus.closed,
                  );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUpdatingTicket = ref.watch(supportChatViewModelProvider(_ticket.id)
        .select((value) => value.updateTicketState is LoadingState));
    ref.listen(supportChatViewModelProvider(_ticket.id), (previous, next) {
      switch (next.updateTicketState) {
        case SuccessState(data: final data):
          _ticket = data;
          setState(() {});
          break;
        case ErrorState(message: final message):
          showSnackbar(context, message, state: SnackbarState.error);
        default:
          break;
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AppPallete.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _ticket.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (isUpdatingTicket)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const LoadingIndicatorWidget(size: 16, color: Colors.white),
            )
          else if (_ticket.status == SupportTicketStatus.open)
            TextButton.icon(
              onPressed: _closeTicket,
              icon: const Icon(Icons.check_circle_outline, size: 16, color: Colors.white),
              label: const Text(
                'Close',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildTicketInfoHeader(),
          Expanded(
            child: _buildMessageList(),
          ),
          if (_ticket.status == SupportTicketStatus.open)
            _buildMessageInput()
          else
            _buildClosedTicketBanner(),
        ],
      ),
    );
  }

  Widget _buildTicketInfoHeader() {
    return InkWell(
      onTap: () {
        setState(() {
          _isTicketInfoExpanded = !_isTicketInfoExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: _ticket.status.getStatusColor().withAlpha(24),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      _ticket.status == SupportTicketStatus.open ? 'Terbuka' : 'Ditutup',
                      style: TextStyle(
                        color: _ticket.status.getStatusColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ProfilePictureWidget(
                    user: _ticket.user,
                    radius: 14,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _ticket.user.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppPallete.neutralColor.shade700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('dd MMM yyyy').format(_ticket.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppPallete.neutralColor.shade500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isTicketInfoExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppPallete.neutralColor.shade500,
                    size: 18,
                  ),
                ],
              ),
            ),

            // Expandable description
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState:
                  _isTicketInfoExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              firstChild: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppPallete.neutralColor.shade100,
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'Deskripsi',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppPallete.neutralColor.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _ticket.description,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: AppPallete.neutralColor.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              secondChild: const SizedBox(height: 0, width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    if (_isLoading) {
      return const CustomLoadingWidget(
        title: 'Memuat pesan',
        subtitle: 'Mohon tunggu sementara kami memuat pesan',
      );
    }

    if (_hasError) {
      return CustomErrorWidget(
        title: 'Gagal memuat pesan',
        onPressed: _retryLoadMessages,
        error: _errorMessage,
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppPallete.neutralColor.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 32,
                color: AppPallete.neutralColor.shade500,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada pesan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppPallete.neutralColor.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Mulai percakapan dengan mengirim pesan tentang masalah Anda',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppPallete.neutralColor.shade600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isFromCurrentUser = message.user.id == _currentUser?.id;
        final isSameDate = index > 0 &&
            DateFormat('yyyy-MM-dd').format(message.createdAt) ==
                DateFormat('yyyy-MM-dd').format(_messages[index - 1].createdAt);

        return Column(
          children: [
            // Date separator
            if (index == 0 || !isSameDate) _buildDateSeparator(message.createdAt),

            Align(
              alignment: isFromCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isFromCurrentUser ? AppPallete.primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(16).copyWith(
                    bottomLeft: !isFromCurrentUser ? const Radius.circular(0) : null,
                    bottomRight: isFromCurrentUser ? const Radius.circular(0) : null,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isFromCurrentUser) ...[
                      Text(
                        message.user.name,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppPallete.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      message.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                isFromCurrentUser ? Colors.white : AppPallete.neutralColor.shade800,
                            height: 1.4,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        DateFormat('HH:mm').format(message.createdAt),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isFromCurrentUser
                                  ? Colors.white.withAlpha(180)
                                  : AppPallete.neutralColor.shade400,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateSeparator(DateTime dateTime) {
    String formattedDate = DateFormat('MMMM d, yyyy').format(dateTime);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          formattedDate,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppPallete.neutralColor.shade500,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return _ticket.status == SupportTicketStatus.closed
        ? const SizedBox.shrink()
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 6,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Ketik pesan Anda',
                        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppPallete.neutralColor.shade400,
                            ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        filled: true,
                        fillColor: AppPallete.neutralColor.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppPallete.neutralColor.shade800,
                          ),
                      maxLines: null,
                      minLines: 1,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(
                      Icons.send_rounded,
                      size: 22,
                      color: Colors.white,
                    ),
                    color: AppPallete.primaryColor,
                    style: IconButton.styleFrom(backgroundColor: AppPallete.primaryColor),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          );
  }

  Widget _buildClosedTicketBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppPallete.neutralColor.shade200,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF44336).withAlpha(16),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_rounded,
                size: 16,
                color: Color(0xFFF44336),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                'Tiket ini sudah ditutup. Anda tidak dapat mengirim pesan baru.',
                style: TextStyle(
                  color: AppPallete.neutralColor.shade600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
