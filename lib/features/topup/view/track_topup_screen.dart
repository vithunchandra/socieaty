import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socieaty/core/network/api_result.dart';
import 'package:socieaty/features/authentication/provider/get_user_data_provider.dart';
import 'package:socieaty/features/authentication/repository/auth_local_repository.dart';
import 'package:socieaty/features/topup/enum/topup_status_enum.dart';
import 'package:socieaty/features/topup/model/topup.dart';
import 'package:socieaty/features/topup/repository/topup_repository.dart';
import 'package:socieaty/features/topup/socket/response/topup_notification_response.dart';
import 'package:socieaty/features/topup/socket/topup_socket_service.dart';
import 'package:socieaty/features/topup/view/widgets/error_view.dart';
import 'package:socieaty/features/topup/view/widgets/expired_view.dart';
import 'package:socieaty/features/topup/view/widgets/failed_view.dart';
import 'package:socieaty/features/topup/view/widgets/loading_view.dart';
import 'package:socieaty/features/topup/view/widgets/pending_view.dart';
import 'package:socieaty/features/topup/view/widgets/success_view.dart';
import 'package:socieaty/shared/widgets/url_display_bar.dart';
import 'package:socieaty/shared/widgets/webview_navigation_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TrackTopupScreen extends ConsumerStatefulWidget {
  final String topupId;
  const TrackTopupScreen({super.key, required this.topupId});

  @override
  ConsumerState<TrackTopupScreen> createState() => _TrackTopupScreenState();
}

class _TrackTopupScreenState extends ConsumerState<TrackTopupScreen> {
  late TopupSocketService _socketService;

  bool isLoading = true;
  String? _errorMessage;

  Topup? _topupData;

  @override
  void initState() {
    super.initState();
    _socketService = ref.read(topupSocketServiceProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupSocketListeners();
    });
  }

  void _setupSocketListeners() {
    _socketService.initConnection(
      onTopupNotification: _handleTopupUpdate,
      onConnected: () {
        setState(() {
          _fetchTopupData();
        });
      },
    );
  }

  void _fetchTopupData() {
    ref.read(topupRepositoryProvider).trackTopup(widget.topupId).then((value) {
      switch (value) {
        case Success(data: final data):
          setState(() {
            _topupData = data.topup;
            isLoading = false;
            _errorMessage = null;
          });
        case Error(error: final error):
          setState(() {
            _errorMessage = error.message;
            isLoading = false;
          });
      }
    });
  }

  void _handleTopupUpdate(dynamic data) async {
    try {
      final updatedTopup = TopupNotificationResponse.fromJson(data);

      if (updatedTopup.topup.id == widget.topupId) {
        if (mounted) {
          await ref.read(authLocalRepositoryProvider).setUserData(updatedTopup.customer);
          ref.invalidate(getUserDataProvider(updatedTopup.customer.id));

          setState(() {
            _topupData = updatedTopup.topup;
            isLoading = false;
            _errorMessage = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error processing topup data';
          isLoading = false;
        });
      }
    }
  }

  void _handleRetry() {
    setState(() {
      isLoading = true;
      _errorMessage = null;
    });
    _fetchTopupData();
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }

  Widget _buildBody() {
    if (isLoading) {
      return const TopupLoadingView();
    }

    if (_errorMessage != null) {
      return TopupErrorView(
        errorMessage: _errorMessage,
        onRetry: _handleRetry,
      );
    }

    if (_topupData == null) {
      return TopupErrorView(
        errorMessage: 'Tidak dapat memuat data pembayaran',
        onRetry: _handleRetry,
      );
    }

    switch (_topupData!.status) {
      case TopupStatusEnum.pending:
        return TopupPendingView(
          redirectUrl: _topupData!.snapRedirectUrl,
          onDataUpdated: _fetchTopupData,
        );
      case TopupStatusEnum.success:
        return TopupSuccessView(
          topup: _topupData!,
        );
      case TopupStatusEnum.failed:
        return TopupFailedView(
          onRetry: _handleRetry,
        );
      case TopupStatusEnum.expired:
        return const TopupExpiredView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payment',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _buildBody(),
    );
  }
}
