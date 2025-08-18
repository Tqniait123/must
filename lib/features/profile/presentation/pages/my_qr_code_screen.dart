import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/extensions/widget_extensions.dart';
import 'package:must_invest/core/services/qr_code_service.dart';
import 'package:must_invest/core/static/app_assets.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/dialogs/payment_bottom_sheet.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_icon_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/notifications_button.dart';
import 'package:must_invest/core/utils/widgets/long_press_effect.dart';
import 'package:must_invest/features/auth/data/models/payment_request_model.dart';
import 'package:must_invest/features/auth/data/models/user.dart';
import 'package:must_invest/features/home/presentation/widgets/home_user_header_widget.dart';
import 'package:must_invest/features/profile/presentation/widgets/car_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';
// Import the ParkingQrService

class MyQrCodeScreen extends StatefulWidget {
  final Car car;
  final User? user; // Add user parameter to get user info

  const MyQrCodeScreen({super.key, required this.car, this.user});

  @override
  State<MyQrCodeScreen> createState() => _MyQrCodeScreenState();
}

class _MyQrCodeScreenState extends State<MyQrCodeScreen> {
  bool _isLoading = true;
  bool _isRegenerating = false;
  String _qrData = '';
  late Car selectedCar;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    selectedCar = widget.car;
    currentUser = widget.user;
    _generateInitialQrCode();
  }

  Future<void> _generateInitialQrCode() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading delay
    await Future.delayed(const Duration(seconds: 2));

    // Generate QR code using the service
    _generateQrCode();

    setState(() {
      _isLoading = false;
    });
  }

  void _generateQrCode() {
    try {
      // Get user info (you might need to get this from your auth service)
      final userId = currentUser?.id ?? 'USER_${Random().nextInt(999999).toString().padLeft(6, '0')}';
      final userName = currentUser?.name ?? 'Unknown User';

      // Generate QR code using ParkingQrService
      _qrData = ParkingQrService.generateUserQr(
        userId: userId.toString(),
        userName: userName,
        carId: selectedCar.id ?? selectedCar.hashCode.toString(),
        carName: selectedCar.name ?? 'Unknown Car',
        metalPlate: selectedCar.metalPlate ?? 'No Plate',
        carColor: selectedCar.color,
      );
    } catch (e) {
      // Handle error
      print('Error generating QR code: $e');

      // Fallback to simple QR data
      _qrData =
          'must_invest://user/${currentUser?.id ?? 'unknown'}?car=${selectedCar.id}&timestamp=${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  Future<void> _regenerateQrCode() async {
    setState(() {
      _isRegenerating = true;
    });

    // Simulate regeneration delay
    await Future.delayed(const Duration(seconds: 1));

    // Generate new QR code
    _generateQrCode();

    setState(() {
      _isRegenerating = false;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تجديد رمز الاستجابة السريعة بنجاح'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onCarChanged(Car newCar) {
    setState(() {
      selectedCar = newCar;
    });
    _regenerateQrCode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Opacity(
        opacity: 0.1,
        child: FloatingActionButton.extended(
          onPressed: () async {
            // Simulate payment request
            showPaymentRequestBottomSheet(
              context: context,
              request: PaymentRequestModel(
                requesterName: "محمد إبراهيم",
                parkingName: "موقف النصر",
                location: "أسوان - شارع السوق السياحي",
                amount: 75.0,
                pointsEquivalent: 150,
              ),
              onApprove: () {
                print("تمت الموافقة على الدفع ✅");
              },
              onReject: (reason) {
                print("تم رفض الدفع ❌ بسبب: $reason");
              },
            );
          },
          label: Text('Simulate Payment Request', style: context.bodyMedium.s8.copyWith(color: Colors.white)),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomBackButton(),
                Text(LocaleKeys.my_qr.tr(), style: context.titleLarge.copyWith()),
                NotificationsButton(color: Color(0xffEAEAF3), iconColor: AppColors.primary),
              ],
            ),

            // QR Code Section
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Car Selection Widget
                  CarWidget.compact(
                    car: selectedCar,
                    trailing: CustomIconButton(
                      height: 30,
                      width: 30,
                      color: Color(0xffEAEAF3),
                      iconColor: AppColors.primary,
                      iconAsset: AppIcons.changeIc,
                      onPressed: () {
                        showAllCarsBottomSheet(context, onChooseCar: _onCarChanged);
                      },
                    ),
                  ).withPressEffect(
                    onTap: () {
                      showAllCarsBottomSheet(context, onChooseCar: _onCarChanged);
                    },
                  ),
                  24.gap,

                  // QR Code Display
                  Center(child: _isLoading ? _buildLoadingWidget() : _buildQrCodeWidget()),

                  // Car Info Display
                  if (!_isLoading) ...[16.gap, _buildCarInfoWidget()],
                ],
              ),
            ),
          ],
        ).paddingHorizontal(24),
      ),
      bottomNavigationBar: Row(
        children: [
          Expanded(
            child: CustomElevatedButton(
              heroTag: 'cancel',
              onPressed: () {
                context.pop();
              },
              title: LocaleKeys.cancel.tr(),
              backgroundColor: Color(0xffF4F4FA),
              textColor: AppColors.primary.withValues(alpha: 0.5),
              isBordered: false,
            ),
          ),
          16.gap,
          Expanded(
            child: CustomElevatedButton(
              loading: _isRegenerating,
              onPressed: _isRegenerating ? null : _regenerateQrCode,
              title: _isRegenerating ? LocaleKeys.generating.tr() : LocaleKeys.re_generate.tr(),
            ),
          ),
        ],
      ).paddingAll(30),
    );
  }

  Widget _buildLoadingWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)),
                16.gap,
                Text(
                  'جاري إنشاء رمز الاستجابة السريعة...',
                  style: context.bodyMedium.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQrCodeWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // QR Code Container
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: QrImageView(
            data: _qrData,
            version: QrVersions.auto,
            size: 250.0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            dataModuleStyle: QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle, color: AppColors.primary),
            eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.circle),
            errorCorrectionLevel: QrErrorCorrectLevel.M,
            embeddedImage: AssetImage(AppImages.logo),
            embeddedImageStyle: QrEmbeddedImageStyle(size: Size(60, 60)),
          ),
        ),
      ],
    );
  }

  Widget _buildCarInfoWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.directions_car, color: AppColors.primary, size: 20),
              8.gap,
              Text(
                'معلومات السيارة',
                style: context.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          12.gap,
          _buildInfoRow('الاسم:', selectedCar.name ?? 'غير محدد'),
          ...[4.gap, _buildInfoRow('رقم اللوحة:', selectedCar.metalPlate)],
          if (selectedCar.color != null) ...[4.gap, _buildInfoRow('اللون:', selectedCar.color!)],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: context.bodySmall.copyWith(color: Colors.grey[600], fontWeight: FontWeight.w500)),
        ),
        Expanded(child: Text(value, style: context.bodySmall.copyWith(color: Colors.grey[800]))),
      ],
    );
  }
}
