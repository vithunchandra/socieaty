import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TopupPendingView extends StatefulWidget {
  final String redirectUrl;
  final VoidCallback onDataUpdated;

  const TopupPendingView({
    super.key,
    required this.redirectUrl,
    required this.onDataUpdated,
  });

  @override
  State<TopupPendingView> createState() => _TopupPendingViewState();
}

class _TopupPendingViewState extends State<TopupPendingView> {
  late WebViewController controller;
  bool isLoading = true;
  String currentUrl = '';
  bool canGoBack = false;
  bool canGoForward = false;

  @override
  void initState() {
    super.initState();
    currentUrl = widget.redirectUrl;
    _initializeWebView();
  }

  void _initializeWebView() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
              currentUrl = url;
            });
            _updateNavigationButtons();
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
              currentUrl = url;
            });
            _updateNavigationButtons();
          },
          onNavigationRequest: (NavigationRequest request) {
            final host = Uri.parse(request.url).toString();

            if (host.startsWith('blob:')) {
              _fetchBlobData(request.url);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
          onUrlChange: (UrlChange url) {
            if (url.url != null) {
              setState(() {
                currentUrl = url.url!;
              });
              _updateNavigationButtons();
            }
          },
        ),
      )
      ..addJavaScriptChannel(
        'BlobDataChannel',
        onMessageReceived: (JavaScriptMessage message) async {
          try {
            final decodedBytes = base64Decode(message.message);
            final directory = await getApplicationDocumentsDirectory();
            final filePath = '${directory.path}/midtrans_download.png';
            final file = File(filePath);
            await file.writeAsBytes(decodedBytes);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('File downloaded to $filePath'),
                  backgroundColor: AppPallete.successColor,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error downloading file: $e'),
                  backgroundColor: AppPallete.errorColor,
                ),
              );
            }
          }
        },
      )
      ..addJavaScriptChannel(
        'TransactionStatusChannel',
        onMessageReceived: (JavaScriptMessage message) {
          if (message.message.isNotEmpty) {
            try {
              final statusData = jsonDecode(message.message);
              debugPrint('Transaction status received: $statusData');
              widget.onDataUpdated();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Transaction status: ${statusData['status_message'] ?? statusData['status'] ?? 'Updated'}'),
                    backgroundColor: AppPallete.infoColor,
                  ),
                );
              }
            } catch (e) {
              debugPrint('Error parsing transaction status: $e');
            }
          }
        },
      )
      ..loadRequest(Uri.parse(widget.redirectUrl));
  }

  Future<void> _updateNavigationButtons() async {
    if (!mounted) return;

    final canGoBackValue = await controller.canGoBack();
    final canGoForwardValue = await controller.canGoForward();

    if (mounted && (canGoBackValue != canGoBack || canGoForwardValue != canGoForward)) {
      setState(() {
        canGoBack = canGoBackValue;
        canGoForward = canGoForwardValue;
      });
    }
  }

  void _fetchBlobData(String blobUrl) async {
    final script = '''
      (async function() {
        try {
          const response = await fetch('$blobUrl');
          const blob = await response.blob();
          const reader = new FileReader();
          reader.onloadend = function() {
            const base64data = reader.result.split(',')[1];
            BlobDataChannel.postMessage(base64data);
          };
          reader.readAsDataURL(blob);
        } catch (error) {
          console.error("Error fetching blob:", error);
        }
      })();
    ''';
    controller.runJavaScript(script);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: controller),
        if (isLoading)
          Container(
            color: Colors.white,
            child: Center(
              child: CircularProgressIndicator(
                color: AppPallete.primaryColor,
              ),
            ),
          ),
      ],
    );
  }
}
