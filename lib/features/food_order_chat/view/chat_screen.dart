import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/enums/user_role.enum.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/food_order_chat/provider/track_food_order_transaction_message_provider.dart';
import 'package:socieaty/features/food_order_chat/viewmodel/chat_view_model.dart';
import 'package:socieaty/features/transaction/model/food_order_transaction.dart';
import 'package:socieaty/features/transaction/model/food_order_transaction_message.dart';
import 'package:socieaty/features/transaction/customer/socket/transaction_messages_socket_service.dart';
import 'package:socieaty/features/user/model/socieaty_user.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final FoodOrderTransaction order;

  const ChatScreen({
    super.key,
    required this.order,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late TransactionMessagesSocketService _transactionMessagesSocketService;
  SocieatyUser? _currentUser;

  List<FoodOrderTransactionMessage> _messages = List.empty(growable: true);
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _socketConnected = false;

  @override
  void initState() {
    super.initState();
    initializeSocketService();
    _currentUser = ref.read(authLocalRepositoryProvider).getUserData();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _transactionMessagesSocketService.removeListener('transaction-message');
    _transactionMessagesSocketService.disconnect();
    super.dispose();
  }

  void initializeSocketService() {
    debugPrint('Initializing socket service...');
    _transactionMessagesSocketService = ref.read(transactionMessagesSocketServiceProvider);

    _transactionMessagesSocketService.onConnected = () {
      debugPrint('Socket connected! Now loading messages for order: ${widget.order.id}');
      if (mounted) {
        setState(() {
          _socketConnected = true;
        });

        _loadMessages();
      }
    };

    _transactionMessagesSocketService.initConnection();

    _transactionMessagesSocketService.listenNewTransactionMessage((message) {
      debugPrint('New transaction message: ${message.toString()}');
      if (message.transactionId == widget.order.id) {
        if (mounted) {
          setState(() {
            _messages.add(message);
          });

          _scrollToBottom();
        }
      }
    });
  }

  void _loadMessages() {
    ref.invalidate(trackFoodOrderTransactionMessageProvider(widget.order.id));
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
        .read(chatViewModelProvider.notifier)
        .createMessage(widget.order.id, _messageController.text);
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

  @override
  Widget build(BuildContext context) {
    ref.listen(trackFoodOrderTransactionMessageProvider(widget.order.id), (previous, next) {
      switch (next) {
        case AsyncData(value: final data):
          setState(() {
            _messages = List<FoodOrderTransactionMessage>.from(data);
            _isLoading = false;
            _hasError = false;
          });
          _scrollToBottom();
        case AsyncError(error: final error):
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = error.toString();
          });
          showSnackbar(context, error.toString(), isError: true);
        case AsyncLoading():
          setState(() {
            _isLoading = true;
          });
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppPallete.primaryColor,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  NetworkImage(widget.order.restaurant.restaurantData.restaurantBannerUrl),
              backgroundColor: AppPallete.neutralColor.shade200,
              radius: 16,
              onBackgroundImageError: (_, __) {},
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.order.restaurant.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Order #${widget.order.id.substring(0, 8)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withAlpha(200),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (!_socketConnected)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sync, size: 14, color: Colors.amber.shade800),
                      const SizedBox(width: 4),
                      Text(
                        'Connecting...',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.amber.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessagesList(),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: () {},
                    color: AppPallete.neutralColor.shade600,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppPallete.neutralColor.shade100,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: null,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _sendMessage,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppPallete.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppPallete.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              _socketConnected ? 'Loading messages...' : 'Connecting to server...',
              style: TextStyle(
                color: AppPallete.neutralColor.shade600,
              ),
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load messages',
              style: TextStyle(
                color: AppPallete.neutralColor.shade700,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(
                color: AppPallete.neutralColor.shade600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _retryLoadMessages,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPallete.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: AppPallete.neutralColor.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(
                color: AppPallete.neutralColor.shade700,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Send your first message to the restaurant',
              style: TextStyle(
                color: AppPallete.neutralColor.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isFromCurrentUser = message.user.id != _currentUser?.id;

        return Align(
          alignment: isFromCurrentUser ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isFromCurrentUser ? Colors.white : AppPallete.primaryColor,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomLeft: isFromCurrentUser ? const Radius.circular(0) : null,
                bottomRight: !isFromCurrentUser ? const Radius.circular(0) : null,
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
                if (isFromCurrentUser) ...[
                  Text(
                    message.user.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppPallete.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  message.message,
                  style: TextStyle(
                    color: isFromCurrentUser ? Colors.black87 : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    '12:30 PM',
                    style: TextStyle(
                      fontSize: 10,
                      color: isFromCurrentUser ? Colors.grey : Colors.white.withAlpha(180),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
