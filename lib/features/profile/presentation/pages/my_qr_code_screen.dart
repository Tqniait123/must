import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/extensions/widget_extensions.dart';
import 'package:must_invest/core/static/app_assets.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_icon_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/notifications_button.dart';
import 'package:must_invest/core/utils/widgets/long_press_effect.dart';
import 'package:must_invest/features/auth/data/models/user.dart';
import 'package:must_invest/features/home/presentation/widgets/home_user_header_widget.dart';
import 'package:must_invest/features/profile/presentation/widgets/car_widget.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Add this dependency

class MyQrCodeScreen extends StatefulWidget {
  final Car car;
  const MyQrCodeScreen({super.key, required this.car});

  @override
  State<MyQrCodeScreen> createState() => _MyQrCodeScreenState();
}

class _MyQrCodeScreenState extends State<MyQrCodeScreen> {
  bool _isLoading = true;
  bool _isRegenerating = false;
  String _userId = '';
  String _qrData = '';
  late Car selectedCar;

  @override
  void initState() {
    super.initState();
    selectedCar = widget.car;
    _generateInitialQrCode();
  }

  Future<void> _generateInitialQrCode() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading delay
    await Future.delayed(const Duration(seconds: 2));

    // Generate user ID and QR data
    _generateQrCode();

    setState(() {
      _isLoading = false;
    });
  }

  void _generateQrCode() {
    // Simulate user ID generation (replace with actual user ID from your auth system)
    _userId = 'USER_${Random().nextInt(999999).toString().padLeft(6, '0')}';

    // Create QR data with user information
    _qrData =
        'must_invest://user/$_userId?timestamp=${DateTime.now().millisecondsSinceEpoch}';
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

    // // Show success message
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(LocaleKeys.qr_code_regenerated.tr()),
    //     backgroundColor: AppColors.primary,
    //     duration: const Duration(seconds: 2),
    //   ),
    // );
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
                Text(
                  LocaleKeys.my_qr.tr(),
                  style: context.titleLarge.copyWith(),
                ),
                NotificationsButton(
                  color: Color(0xffEAEAF3),
                  iconColor: AppColors.primary,
                ),
              ],
            ),

            // QR Code Section
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CarWidget.custom(
                    car: selectedCar,
                    trailing: CustomIconButton(
                      height: 30,
                      width: 30,
                      color: Color(0xffEAEAF3),
                      iconColor: AppColors.primary,
                      iconAsset: AppIcons.changeIc,

                      onPressed: () {
                        showAllCarsBottomSheet(
                          context,
                          onChooseCar: (car) {
                            setState(() {
                              selectedCar = car;
                              _regenerateQrCode();
                            });
                          },
                        );
                      },
                    ),
                  ).withPressEffect(
                    onTap: () {
                      showAllCarsBottomSheet(
                        context,
                        onChooseCar: (car) {
                          setState(() {
                            selectedCar = car;
                            _regenerateQrCode();
                          });
                        },
                      );
                    },
                  ),
                  24.gap,
                  Center(
                    child:
                        _isLoading
                            ? _buildLoadingWidget()
                            : _buildQrCodeWidget(),
                  ),
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
              title:
                  _isRegenerating
                      ? LocaleKeys.generating.tr()
                      : LocaleKeys.re_generate.tr(),
              // child:
              //     _isRegenerating
              //         ? Row(
              //           mainAxisSize: MainAxisSize.min,
              //           children: [
              //             SizedBox(
              //               width: 16,
              //               height: 16,
              //               child: CircularProgressIndicator(
              //                 strokeWidth: 2,
              //                 valueColor: AlwaysStoppedAnimation<Color>(
              //                   Colors.white,
              //                 ),
              //               ),
              //             ),
              //             8.gap,
              //             Text(LocaleKeys.generating.tr()),
              //           ],
              //         )
              //         : null,
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
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                16.gap,
                // Text(
                //   LocaleKeys.generating_qr_code.tr(),
                //   style: context.bodyMedium.copyWith(color: Colors.grey[600]),
                // ),
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: QrImageView(
            data: _qrData,
            version: QrVersions.auto,
            size: 250.0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            dataModuleStyle: QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.circle,
              color: AppColors.primary,
            ),
            eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.circle),
            errorCorrectionLevel: QrErrorCorrectLevel.M,
            embeddedImage: AssetImage(
              AppImages.logo,
            ), // Optional: Add your app logo
            embeddedImageStyle: QrEmbeddedImageStyle(size: Size(60, 60)),
          ),
        ),

        24.gap,

        // // User ID Display
        // Container(
        //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        //   decoration: BoxDecoration(
        //     color: AppColors.primary.withOpacity(0.1),
        //     borderRadius: BorderRadius.circular(12),
        //   ),
        //   child: Row(
        //     mainAxisSize: MainAxisSize.min,
        //     children: [
        //       Icon(Icons.person_outline, color: AppColors.primary, size: 20),
        //       8.gap,
        //       Text(
        //         'ID: $_userId',
        //         style: context.bodyMedium.copyWith(
        //           color: AppColors.primary,
        //           fontWeight: FontWeight.w600,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        16.gap,

        // Instructions
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 40),
        //   child: Text(
        //     LocaleKeys.qr_code_instructions.tr(),
        //     textAlign: TextAlign.center,
        //     style: context.bodySmall.copyWith(color: Colors.grey[600]),
        //   ),
        // ),
      ],
    );
  }
}
