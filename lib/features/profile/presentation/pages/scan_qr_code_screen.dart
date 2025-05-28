import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // Modern QR scanner package
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/extensions/widget_extensions.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/notifications_button.dart';

class ScanQrCodeScreen extends StatefulWidget {
  const ScanQrCodeScreen({super.key});

  @override
  State<ScanQrCodeScreen> createState() => _ScanQrCodeScreenState();
}

class _ScanQrCodeScreenState extends State<ScanQrCodeScreen> {
  MobileScannerController controller = MobileScannerController();
  bool _isScanning = true;
  bool _isProcessing = false;
  String? _scannedData;
  bool _flashOn = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BuildContext context, BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && !_isProcessing && _isScanning) {
      final barcode = barcodes.first;
      if (barcode.rawValue != null) {
        _handleScannedData(context, barcode.rawValue!);
      }
    }
  }

  Future<void> _handleScannedData(
    BuildContext context,
    String scannedData,
  ) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _scannedData = scannedData;
    });

    // Stop scanning
    await controller.stop();

    // Process the scanned data
    await _processQrCode(context, scannedData);

    setState(() {
      _isProcessing = false;
    });
  }

  Future<void> _processQrCode(BuildContext context, String qrData) async {
    try {
      // Show processing indicator
      _showProcessingDialog();

      // Simulate processing delay
      await Future.delayed(const Duration(seconds: 2));

      // Hide processing dialog
      Navigator.of(context).pop();

      // Check if QR code is valid
      if (_isValidQrCode(qrData)) {
        _showSuccessDialog(context, qrData);
      } else {
        _showErrorDialog(LocaleKeys.invalid_qr_code.tr());
      }
    } catch (e) {
      Navigator.of(context).pop();
      _showErrorDialog(LocaleKeys.error_processing_qr.tr());
    }
  }

  bool _isValidQrCode(String qrData) {
    // Add your QR code validation logic here
    // For example, check if it contains your app's scheme
    return qrData.isNotEmpty &&
        (qrData.startsWith('must_invest://') ||
            qrData.startsWith('http') ||
            qrData.length > 5);
  }

  void _showProcessingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                16.gap,
                Text(LocaleKeys.processing.tr(), style: context.bodyMedium),
              ],
            ),
          ),
    );
  }

  void _showSuccessDialog(BuildContext context, String qrData) {
    context.pop();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(LocaleKeys.error.tr()),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resumeScanning();
                },
                child: Text(LocaleKeys.try_again.tr()),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.pop();
                },
                child: Text(LocaleKeys.cancel.tr()),
              ),
            ],
          ),
    );
  }

  Future<void> _resumeScanning() async {
    setState(() {
      _isScanning = true;
      _scannedData = null;
    });
    await controller.start();
  }

  Future<void> _toggleFlash() async {
    await controller.toggleTorch();
    setState(() {
      _flashOn = !_flashOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomBackButton(),
                // Text(
                //   LocaleKeys.scan_qr_code.tr(),
                //   style: context.titleLarge.copyWith(),
                // ),
                NotificationsButton(
                  color: Color(0xffEAEAF3),
                  iconColor: AppColors.primary,
                ),
              ],
            ).paddingHorizontal(24),

            16.gap,

            // Instructions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                LocaleKeys.scan_qr_instructions.tr(),
                textAlign: TextAlign.center,
                style: context.bodyMedium.copyWith(color: Colors.grey[600]),
              ),
            ),

            24.gap,

            // QR Scanner Section
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    // overflow: Clip.hardEdge,
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: MobileScanner(
                          controller: controller,
                          onDetect: (data) {
                            _onDetect(context, data);
                          },
                          overlayBuilder: (context, capture) {
                            return Container(
                              color: Colors.transparent,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 200,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.qr_code_scanner,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          // overlay: Container(
                          //   decoration: BoxDecoration(
                          //     border: Border.all(
                          //       color: AppColors.primary,
                          //       width: 2,
                          //     ),
                          //     borderRadius: BorderRadius.circular(16),
                          //   ),
                          // ),
                        ),
                      ),

                      // Flash toggle button
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: _toggleFlash,
                            icon: Icon(
                              _flashOn ? Icons.flash_on : Icons.flash_off,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // Scanning indicator
                      if (_isProcessing)
                        Container(
                          color: Colors.black.withOpacity(0.7),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                                16.gap,
                                Text(
                                  LocaleKeys.processing.tr(),
                                  style: context.bodyMedium.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            24.gap,

            // Scanning status
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    _isScanning
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _isScanning ? Colors.green : Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  8.gap,
                  Text(
                    _isScanning
                        ? LocaleKeys.ready_to_scan.tr()
                        : LocaleKeys.processing.tr(),
                    style: context.bodyMedium.copyWith(
                      color: _isScanning ? AppColors.primary : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            24.gap,
          ],
        ),
      ),
      // bottomNavigationBar: Row(
      //   children: [
      //     Expanded(
      //       child: CustomElevatedButton(
      //         heroTag: 'cancel',
      //         onPressed: () {
      //           context.pop();
      //         },
      //         title: LocaleKeys.cancel.tr(),
      //         backgroundColor: Color(0xffF4F4FA),
      //         textColor: AppColors.primary.withValues(alpha: 0.5),
      //         isBordered: false,
      //       ),
      //     ),
      //     16.gap,
      //     Expanded(
      //       child: CustomElevatedButton(
      //         onPressed:
      //             _isProcessing
      //                 ? null
      //                 : () async {
      //                   await _resumeScanning();
      //                 },
      //         title: LocaleKeys.rescan.tr(),
      //         loading: _isProcessing,
      //       ),
      //     ),
      //   ],
      // ).paddingAll(30),
    );
  }
}
