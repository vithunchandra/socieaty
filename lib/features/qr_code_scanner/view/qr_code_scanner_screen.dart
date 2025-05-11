import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/shared/widgets/loading_indicator_widget.dart';

class QrCodeScannerArgs {
  final String title;
  final String helperMessage;

  const QrCodeScannerArgs({
    this.title = 'Scan QR Code',
    this.helperMessage = 'Atur QR Code dalam frame untuk scan',
  });
}

class QrCodeScannerScreen extends ConsumerStatefulWidget {
  final QrCodeScannerArgs args;

  const QrCodeScannerScreen({
    super.key,
    required this.args,
  });

  @override
  ConsumerState<QrCodeScannerScreen> createState() => _QrCodeScannerScreenState();
}

class _QrCodeScannerScreenState extends ConsumerState<QrCodeScannerScreen>
    with WidgetsBindingObserver {
  late MobileScannerController _scannerController;
  final bool _showProcessingOverlay = true;
  final double _scanWindowSize = 250;
  final double _scanWindowBorderRadius = 16;
  bool _isTorchOn = false;
  bool _isFrontCamera = false;
  bool _isProcessingQR = false;
  String? _lastScannedCode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _scannerController.start();
    } else if (state == AppLifecycleState.inactive) {
      _scannerController.stop();
    }
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessingQR) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        final code = barcode.rawValue!;

        // Prevent scanning the same code multiple times
        if (_lastScannedCode == code) return;
        _lastScannedCode = code;

        _processQrCode(code);
        break;
      }
    }
  }

  Future<void> _processQrCode(String code) async {
    // If showing processing overlay is enabled, show it
    if (_showProcessingOverlay) {
      setState(() {
        _isProcessingQR = true;
      });
    }

    try {
      context.pop(code);
    } finally {
      // If we showed the processing overlay, hide it
      if (_showProcessingOverlay) {
        setState(() {
          _isProcessingQR = false;
        });
      }

      // Reset last scanned code after a delay to allow scanning the same code again
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _lastScannedCode = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final centerOffset = size.center(Offset.zero);

    // Calculate position for the scan window
    final scanWindowLeft = centerOffset.dx - (_scanWindowSize / 2);
    final scanWindowTop = centerOffset.dy - (_scanWindowSize / 2);

    // Create the scan window rect for the scanner
    final scanWindow =
        Rect.fromLTWH(scanWindowLeft, scanWindowTop, _scanWindowSize, _scanWindowSize);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.args.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Scanner
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
            scanWindow: scanWindow,
          ),

          // Overlay with cutout using CustomPainter
          CustomPaint(
            painter: ScanOverlayPainter(
              scanWindow: scanWindow,
              borderRadius: _scanWindowBorderRadius,
              overlayColor: Colors.black.withAlpha(128),
              borderColor: AppPallete.primaryColor,
              borderWidth: 2.5,
            ),
            child: SizedBox(
              width: size.width,
              height: size.height,
            ),
          ),

          // Camera controls - horizontal below scan window
          Positioned(
            top: scanWindowTop + _scanWindowSize + 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(
                      icon: _isTorchOn ? Icons.flash_on : Icons.flash_off,
                      label: _isTorchOn ? 'Aktif' : 'Nonaktif',
                      onPressed: () {
                        setState(() {
                          _isTorchOn = !_isTorchOn;
                          _scannerController.toggleTorch();
                        });
                      },
                    ),
                    const SizedBox(width: 56),
                    _buildControlButton(
                      icon: Icons.flip_camera_android,
                      label: 'Putar',
                      onPressed: () {
                        setState(() {
                          _isFrontCamera = !_isFrontCamera;
                          _scannerController.switchCamera();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Processing overlay
          if (_isProcessingQR && _showProcessingOverlay)
            Container(
              color: Colors.black.withAlpha(120),
              child: Center(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: const LoadingIndicatorWidget(size: 36),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Memproses...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppPallete.neutralColor.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Helper message
          Positioned(
            bottom: 64,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(160),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  widget.args.helperMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for overlay with cutout
class ScanOverlayPainter extends CustomPainter {
  final Rect scanWindow;
  final double borderRadius;
  final Color overlayColor;
  final Color borderColor;
  final double borderWidth;

  ScanOverlayPainter({
    required this.scanWindow,
    required this.borderRadius,
    required this.overlayColor,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = overlayColor;

    // Create a path for the entire screen
    final backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create a path for the scan window with rounded corners
    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          scanWindow,
          Radius.circular(borderRadius),
        ),
      );

    // Create the path for the overlay with the cutout
    final path = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    // Draw the overlay with the cutout
    canvas.drawPath(path, backgroundPaint);

    // Draw the border around the scan window
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        scanWindow,
        Radius.circular(borderRadius),
      ),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(ScanOverlayPainter oldDelegate) =>
      oldDelegate.scanWindow != scanWindow ||
      oldDelegate.borderRadius != borderRadius ||
      oldDelegate.overlayColor != overlayColor ||
      oldDelegate.borderColor != borderColor ||
      oldDelegate.borderWidth != borderWidth;
}
