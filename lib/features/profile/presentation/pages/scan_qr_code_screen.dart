import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // Modern QR scanner package
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/extensions/widget_extensions.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_icon_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/notifications_button.dart';
import 'package:must_invest/core/utils/widgets/long_press_effect.dart';
import 'package:must_invest/features/auth/data/models/user.dart';
import 'package:must_invest/features/home/presentation/widgets/home_user_header_widget.dart';
import 'package:must_invest/features/profile/presentation/widgets/car_widget.dart';

class ScanQrCodeScreen extends StatefulWidget {
  final Car? selectedCar;
  const ScanQrCodeScreen({super.key, this.selectedCar});

  @override
  State<ScanQrCodeScreen> createState() => _ScanQrCodeScreenState();
}

class _ScanQrCodeScreenState extends State<ScanQrCodeScreen> {
  MobileScannerController controller = MobileScannerController();
  bool _isScanning = true;
  bool _isProcessing = false;
  String? _scannedData;
  bool _flashOn = false;
  late Car? selectedCar;

  @override
  void initState() {
    super.initState();
    selectedCar = widget.selectedCar;
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

  Future<void> _handleScannedData(BuildContext context, String scannedData) async {
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
    return qrData.isNotEmpty && (qrData.startsWith('must_invest://') || qrData.startsWith('http') || qrData.length > 5);
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
                CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)),
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
                Text(LocaleKeys.scan_qr_code.tr(), style: context.titleLarge.copyWith()),
                NotificationsButton(color: Color(0xffEAEAF3), iconColor: AppColors.primary),
              ],
            ).paddingHorizontal(24),

            16.gap,

            // Car Selection Widget (if car is selected)
            if (selectedCar != null) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: CarWidget.custom(
                  car: selectedCar!,
                  trailing: CustomIconButton(
                    height: 30,
                    width: 30,
                    color: Color(0xffEAEAF3),
                    iconColor: AppColors.primary,
                    iconAsset: AppIcons.changeIc,
                    onPressed: () {
                      showAllCarsBottomSheet(
                        context,
                        title: LocaleKeys.select_car.tr(),
                        onChooseCar: (car) {
                          setState(() {
                            selectedCar = car;
                          });
                        },
                      );
                    },
                  ),
                ).withPressEffect(
                  onTap: () {
                    showAllCarsBottomSheet(
                      context,
                      title: LocaleKeys.select_car.tr(),
                      onChooseCar: (car) {
                        setState(() {
                          selectedCar = car;
                        });
                      },
                    );
                  },
                ),
              ),
              16.gap,
            ],

            // Car selection prompt (if no car is selected)
            if (selectedCar == null) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                    12.gap,
                    Expanded(
                      child: Text(
                        LocaleKeys.select_car.tr(),
                        style: context.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w500),
                      ),
                    ),
                    CustomIconButton(
                      height: 32,
                      width: 32,
                      color: AppColors.primary,
                      iconColor: Colors.white,
                      iconAsset: AppIcons.carIc,
                      onPressed: () {
                        showAllCarsBottomSheet(
                          context,
                          title: LocaleKeys.select_car.tr(),
                          onChooseCar: (car) {
                            setState(() {
                              selectedCar = car;
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
              ).withPressEffect(
                onTap: () {
                  showAllCarsBottomSheet(
                    context,
                    title: LocaleKeys.select_car.tr(),
                    onChooseCar: (car) {
                      setState(() {
                        selectedCar = car;
                      });
                    },
                  );
                },
              ),
              16.gap,
            ],

            // Instructions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                selectedCar != null ? LocaleKeys.scan_qr_instructions.tr() : LocaleKeys.select_car.tr(),
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
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: MobileScanner(
                          controller: controller,
                          onDetect:
                              selectedCar != null
                                  ? (data) {
                                    _onDetect(context, data);
                                  }
                                  : null, // Disable scanning if no car selected
                          overlayBuilder: (context, capture) {
                            return Container(
                              color: selectedCar == null ? Colors.black.withOpacity(0.7) : Colors.transparent,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 200,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        color:
                                            selectedCar != null
                                                ? Colors.black.withOpacity(0.5)
                                                : Colors.black.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              selectedCar != null ? Icons.qr_code_scanner : Icons.no_photography,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                            if (selectedCar == null) ...[
                                              8.gap,
                                              Text(
                                                LocaleKeys.select_car.tr(),
                                                style: context.bodySmall.copyWith(color: Colors.white),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Flash toggle button (only show if car is selected)
                      if (selectedCar != null)
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
                              icon: Icon(_flashOn ? Icons.flash_on : Icons.flash_off, color: Colors.white),
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
                                CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                16.gap,
                                Text(
                                  LocaleKeys.processing.tr(),
                                  style: context.bodyMedium.copyWith(color: Colors.white),
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
                    selectedCar != null
                        ? (_isScanning ? AppColors.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.1))
                        : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: selectedCar != null ? (_isScanning ? Colors.green : Colors.orange) : Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  8.gap,
                  Text(
                    selectedCar != null
                        ? (_isScanning ? LocaleKeys.ready_to_scan.tr() : LocaleKeys.processing.tr())
                        : LocaleKeys.select_car.tr(),
                    style: context.bodyMedium.copyWith(
                      color: selectedCar != null ? (_isScanning ? AppColors.primary : Colors.grey[600]) : Colors.orange,
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
    );
  }
}
