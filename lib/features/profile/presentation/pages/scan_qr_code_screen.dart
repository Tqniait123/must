import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/extensions/widget_extensions.dart';
import 'package:must_invest/core/services/di.dart';
import 'package:must_invest/core/services/qr_code_service.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/dialogs/error_toast.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_icon_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/notifications_button.dart';
import 'package:must_invest/core/utils/widgets/long_press_effect.dart';
import 'package:must_invest/features/auth/data/models/user.dart';
import 'package:must_invest/features/home/presentation/widgets/home_user_header_widget.dart';
import 'package:must_invest/features/profile/data/models/parking_process_model.dart';
import 'package:must_invest/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:must_invest/features/profile/presentation/widgets/car_widget.dart';

class ScanQrCodeScreen extends StatefulWidget {
  final Car? selectedCar;
  final bool isEmployee; // تحديد هل ده موظف ولا يوزر
  const ScanQrCodeScreen({super.key, this.selectedCar, this.isEmployee = false});

  @override
  State<ScanQrCodeScreen> createState() => _ScanQrCodeScreenState();
}

class _ScanQrCodeScreenState extends State<ScanQrCodeScreen> {
  MobileScannerController controller = MobileScannerController();
  bool _isScanning = true;
  bool _isProcessing = false;
  String? _scannedData;
  bool _flashOn = false;
  Car? selectedCar;
  late bool isEmployee;

  @override
  void initState() {
    super.initState();
    selectedCar = widget.selectedCar;
    isEmployee = widget.isEmployee;
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

    // Process the scanned data using new ParkingQR service
    await _processQrCodeWithNewService(context, scannedData);

    setState(() {
      _isProcessing = false;
    });
  }

  Future<void> _processQrCodeWithNewService(BuildContext context, String qrData) async {
    try {
      // Show processing indicator
      _showProcessingDialog();

      // Simulate processing delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Hide processing dialog
      Navigator.of(context).pop();

      QrScanResult result;

      if (isEmployee) {
        // الموظف بيسكان QR اليوزر عشان يعرف بيانات العربية
        result = ParkingQrService.scanUserQr(qrData);
      } else {
        // اليوزر بيسكان QR الموظف عشان يعرف مين دخله
        result = ParkingQrService.scanEmployeeQr(qrData);
      }

      if (result.isValid) {
        if (isEmployee && result.userData != null) {
          _showUserDataBottomSheet(context, result.userData!);
        } else if (!isEmployee && result.employeeData != null) {
          _showEmployeeDataBottomSheet(context, result.employeeData!);
        }
      } else {
        _showErrorBottomSheet(result.error ?? 'Failed to process QR code');
      }
    } catch (e) {
      Navigator.of(context).pop();
      _showErrorBottomSheet('Error processing QR code: $e');
    }
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

  // عرض بيانات اليوزر للموظف - Bottom Sheet
  void _showUserDataBottomSheet(BuildContext context, UserQrData userData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
            child: DraggableScrollableSheet(
              initialChildSize: 0.85,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder:
                  (context, scrollController) => SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Handle bar
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          20.gap,

                          // Success Icon and Title
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.green.withOpacity(0.3), width: 2),
                                  ),
                                  child: Icon(Icons.qr_code_scanner, color: Colors.green, size: 40),
                                ),
                                16.gap,
                                Text(
                                  'تم العثور على بيانات العربية',
                                  style: context.titleLarge.copyWith(fontWeight: FontWeight.bold, color: Colors.green),
                                ),
                                8.gap,
                                Text(
                                  'تفاصيل العميل والعربية',
                                  style: context.bodyMedium.copyWith(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          32.gap,

                          // User Badge
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue.withOpacity(0.1), Colors.blue.withOpacity(0.05)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.blue.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(8)),
                                  child: Icon(Icons.person, color: Colors.white, size: 20),
                                ),
                                12.gap,
                                Text(
                                  'بيانات العميل',
                                  style: context.titleMedium.copyWith(color: Colors.blue, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          16.gap,

                          // User Information Cards
                          _buildModernInfoCard('اسم العميل', userData.userName, Icons.person, Colors.blue),
                          8.gap,
                          _buildModernInfoCard('ID العميل', userData.userId, Icons.badge, Colors.blue),
                          24.gap,

                          // Car Information Section
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0.05)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.green.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.directions_car, color: Colors.white, size: 20),
                                ),
                                12.gap,
                                Text(
                                  'بيانات العربية',
                                  style: context.titleMedium.copyWith(color: Colors.green, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          16.gap,

                          _buildModernInfoCard('نوع العربية', userData.carName, Icons.car_rental, Colors.green),
                          8.gap,
                          _buildModernInfoCard(
                            'رقم اللوحة',
                            userData.metalPlate,
                            Icons.confirmation_number,
                            Colors.green,
                          ),
                          8.gap,
                          _buildModernInfoCard('ID العربية', userData.carId, Icons.key, Colors.green),
                          if (userData.carColor != null) ...[
                            8.gap,
                            _buildModernInfoCard('اللون', userData.carColor!, Icons.palette, Colors.green),
                          ],

                          32.gap,

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 52,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _resumeScanning();
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.grey[300]!),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.qr_code_scanner, size: 20, color: Colors.grey[600]),
                                        8.gap,
                                        Text(
                                          'سكان آخر',
                                          style: context.bodyLarge.copyWith(
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              16.gap,
                              Expanded(
                                child: SizedBox(
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _handleUserCarEntry(userData);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check_circle, size: 20),
                                        8.gap,
                                        Text(
                                          'تأكيد الدخول',
                                          style: context.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          24.gap,
                        ],
                      ),
                    ),
                  ),
            ),
          ),
    );
  }

  // عرض بيانات الموظف لليوزر - Bottom Sheet
  void _showEmployeeDataBottomSheet(BuildContext context, EmployeeQrData employeeData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
            child: DraggableScrollableSheet(
              initialChildSize: 0.85,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder:
                  (context, scrollController) => SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Handle bar
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          20.gap,

                          // Success Icon and Title
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.green.withOpacity(0.3), width: 2),
                                  ),
                                  child: Icon(Icons.verified_user, color: Colors.green, size: 40),
                                ),
                                16.gap,
                                Text(
                                  'تم العثور على الموظف',
                                  style: context.titleLarge.copyWith(fontWeight: FontWeight.bold, color: Colors.green),
                                ),
                                8.gap,
                                Text(
                                  'بيانات موظف الاستقبال',
                                  style: context.bodyMedium.copyWith(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          32.gap,

                          // Employee Badge
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0.05)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.green.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.badge, color: Colors.white, size: 20),
                                ),
                                12.gap,
                                Text(
                                  'موظف معتمد',
                                  style: context.titleMedium.copyWith(color: Colors.green, fontWeight: FontWeight.bold),
                                ),
                                Spacer(),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'موثق',
                                    style: context.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          16.gap,

                          // Employee Information
                          _buildModernInfoCard('اسم الموظف', employeeData.employeeName, Icons.person, Colors.green),
                          8.gap,
                          _buildModernInfoCard('ID الموظف', employeeData.employeeId, Icons.badge, Colors.green),
                          24.gap,

                          // Work Information Section
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue.withOpacity(0.1), Colors.blue.withOpacity(0.05)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.blue.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(8)),
                                  child: Icon(Icons.work, color: Colors.white, size: 20),
                                ),
                                12.gap,
                                Text(
                                  'بيانات العمل',
                                  style: context.titleMedium.copyWith(color: Colors.blue, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          16.gap,

                          _buildModernInfoCard(
                            'مكان الركن',
                            employeeData.parkingLocation,
                            Icons.location_on,
                            Colors.blue,
                          ),
                          8.gap,
                          _buildModernInfoCard('وردية العمل', employeeData.shiftTime, Icons.access_time, Colors.blue),
                          16.gap,

                          // Scan Time Info
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.purple.withOpacity(0.1), Colors.purple.withOpacity(0.05)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.purple.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.purple,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.schedule, color: Colors.white, size: 16),
                                ),
                                12.gap,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'وقت السكان',
                                        style: context.bodySmall.copyWith(
                                          color: Colors.purple,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      4.gap,
                                      Text(
                                        DateFormat('HH:mm:ss - dd/MM/yyyy').format(DateTime.now()),
                                        style: context.bodyMedium.copyWith(
                                          color: Colors.purple[700],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          32.gap,

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 52,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _resumeScanning();
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.grey[300]!),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.qr_code_scanner, size: 20, color: Colors.grey[600]),
                                        8.gap,
                                        Text(
                                          'سكان آخر',
                                          style: context.bodyLarge.copyWith(
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              16.gap,
                              Expanded(
                                child: BlocProvider(
                                  create: (BuildContext context) => ProfileCubit(sl()),
                                  child: BlocConsumer<ProfileCubit, ProfileState>(
                                    listener: (BuildContext context, ProfileState state) {
                                      if (state is StartParkingSuccess) {
                                        Navigator.of(context).pop();
                                        _handleEmployeeConfirmation(employeeData);
                                      }
                                      if (state is StartParkingError) {
                                        showErrorToast(context, state.message);
                                      }
                                    },
                                    builder:
                                        (BuildContext context, ProfileState state) => SizedBox(
                                          child: CustomElevatedButton(
                                            loading: state is StartParkingLoading,
                                            onPressed: () {
                                              ProfileCubit.get(context).startParking(
                                                ParkingProcessModel(
                                                  car: selectedCar!,
                                                  employerId: employeeData.employeeId.toString(),
                                                ),
                                              );
                                            },
                                            title: 'تأكيد',
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          24.gap,
                        ],
                      ),
                    ),
                  ),
            ),
          ),
    );
  }

  // Error Bottom Sheet with modern design
  void _showErrorBottomSheet(String message) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
            child: DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.8,
              expand: false,
              builder:
                  (context, scrollController) => SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Handle bar
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                          ),
                          20.gap,

                          // Error Icon and Title
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
                            ),
                            child: Icon(Icons.error_outline, color: Colors.red, size: 40),
                          ),
                          16.gap,

                          Text(
                            'فشل في قراءة الـ QR',
                            style: context.titleLarge.copyWith(fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                          8.gap,

                          Text(
                            'حدث خطأ أثناء معالجة الكود',
                            style: context.bodyMedium.copyWith(color: Colors.grey[600]),
                          ),
                          24.gap,

                          // Error Message Container
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.red.withOpacity(0.2)),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.info_outline, color: Colors.red, size: 20),
                                    8.gap,
                                    Text(
                                      'تفاصيل الخطأ',
                                      style: context.bodyMedium.copyWith(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                12.gap,
                                Text(
                                  message,
                                  style: context.bodyMedium.copyWith(color: Colors.red[700], height: 1.4),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          32.gap,

                          // Suggestions Container
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.blue.withOpacity(0.2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.lightbulb_outline, color: Colors.blue, size: 20),
                                    8.gap,
                                    Text(
                                      'نصائح',
                                      style: context.bodyMedium.copyWith(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                12.gap,
                                _buildSuggestionItem('تأكد من وضوح الـ QR كود'),
                                _buildSuggestionItem('تأكد من إضاءة جيدة'),
                                _buildSuggestionItem('اقترب أو ابتعد قليلاً عن الكود'),
                                _buildSuggestionItem('تأكد من صحة نوع الـ QR كود'),
                              ],
                            ),
                          ),
                          32.gap,

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 52,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      context.pop();
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.grey[300]!),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.close, size: 20, color: Colors.grey[600]),
                                        8.gap,
                                        Text(
                                          LocaleKeys.cancel.tr(),
                                          style: context.bodyLarge.copyWith(
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              16.gap,
                              Expanded(
                                child: SizedBox(
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _resumeScanning();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.refresh, size: 20),
                                        8.gap,
                                        Text(
                                          LocaleKeys.try_again.tr(),
                                          style: context.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          24.gap,
                        ],
                      ),
                    ),
                  ),
            ),
          ),
    );
  }

  Widget _buildSuggestionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(width: 4, height: 4, decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle)),
          8.gap,
          Expanded(child: Text(text, style: context.bodySmall.copyWith(color: Colors.blue[700], height: 1.3))),
        ],
      ),
    );
  }

  Widget _buildModernInfoCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          12.gap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.bodySmall.copyWith(color: Colors.grey[600], fontWeight: FontWeight.w500)),
                4.gap,
                Text(value, style: context.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: Colors.grey[800])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: context.bodySmall.copyWith(fontWeight: FontWeight.w600, color: Colors.grey[600]),
            ),
          ),
          4.gap,
          Expanded(child: Text(value, style: context.bodySmall.copyWith(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  // معالجة دخول عربية اليوزر (للموظف)
  void _handleUserCarEntry(UserQrData userData) {
    // هنا الموظف يحفظ بيانات دخول العربية في الداتابيز
    print('🚗 الموظف: تم تأكيد دخول العربية');
    print('- صاحب العربية: ${userData.userName}');
    print('- نوع العربية: ${userData.carName}');
    print('- رقم اللوحة: ${userData.metalPlate}');
    print('- Car ID للداتابيز: ${userData.carId}');
    print('- User ID للداتابيز: ${userData.userId}');

    _showSuccessBottomSheet(
      title: 'تم تسجيل الدخول بنجاح!',
      message: 'تم تسجيل دخول عربية ${userData.carName} بنجاح',
      icon: Icons.check_circle,
      color: Colors.green,
    );
  }

  // معالجة تأكيد الموظف (لليوزر)
  void _handleEmployeeConfirmation(EmployeeQrData employeeData) {
    // هنا اليوزر يبعت ID الموظف للداتابيز عشان يعرف مين دخله
    print('👤 اليوزر: تم تأكيد الموظف');
    print('- اسم الموظف: ${employeeData.employeeName}');
    print('- مكان الركن: ${employeeData.parkingLocation}');
    print('- Employee ID للداتابيز: ${employeeData.employeeId}');

    _showSuccessBottomSheet(
      title: 'تم تأكيد الموظف بنجاح!',
      message: 'تم التأكيد مع الموظف ${employeeData.employeeName}',
      icon: Icons.verified_user,
      color: Colors.green,
    );

    // TODO: إرسال ID الموظف للداتابيز
    // await sendEmployeeIdToDatabase(employeeData.employeeId);
  }

  // Success Bottom Sheet
  void _showSuccessBottomSheet({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
            child: DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 0.7,
              expand: false,
              builder:
                  (context, scrollController) => SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Handle bar
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                          ),
                          20.gap,

                          // Success Animation Container
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: color.withOpacity(0.2), blurRadius: 20, offset: Offset(0, 10)),
                              ],
                            ),
                            child: Icon(icon, color: color, size: 50),
                          ),
                          24.gap,

                          Text(
                            title,
                            style: context.titleLarge.copyWith(fontWeight: FontWeight.bold, color: color),
                            textAlign: TextAlign.center,
                          ),
                          12.gap,

                          Text(
                            message,
                            style: context.bodyLarge.copyWith(color: Colors.grey[600], height: 1.4),
                            textAlign: TextAlign.center,
                          ),
                          32.gap,

                          // Success Details
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: color.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.schedule, color: color, size: 20),
                                12.gap,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'تم في',
                                        style: context.bodySmall.copyWith(color: color, fontWeight: FontWeight.bold),
                                      ),
                                      4.gap,
                                      Text(
                                        DateFormat('HH:mm:ss - dd/MM/yyyy').format(DateTime.now()),
                                        style: context.bodyMedium.copyWith(color: color, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          32.gap,

                          // Action Button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                context.pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: color,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.home, size: 20),
                                  8.gap,
                                  Text(
                                    'العودة للرئيسية',
                                    style: context.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          24.gap,
                        ],
                      ),
                    ),
                  ),
            ),
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

  void _onCarChanged(Car newCar) {
    setState(() {
      selectedCar = newCar;
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
                Text(isEmployee ? 'سكان QR العميل' : 'سكان QR الموظف', style: context.titleLarge.copyWith()),
                NotificationsButton(color: Color(0xffEAEAF3), iconColor: AppColors.primary),
              ],
            ).paddingHorizontal(24),

            16.gap,

            // Car Selection Widget (for both employee and user)
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
                      showAllCarsBottomSheet(context, title: LocaleKeys.select_car.tr(), onChooseCar: _onCarChanged);
                    },
                  ),
                ).withPressEffect(
                  onTap: () {
                    showAllCarsBottomSheet(context, title: LocaleKeys.select_car.tr(), onChooseCar: _onCarChanged);
                  },
                ),
              ),
              16.gap,
            ] else ...[
              // Instructions when no car is selected
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isEmployee ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isEmployee ? Colors.green.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isEmployee ? Icons.badge : Icons.person,
                        color: isEmployee ? Colors.green : Colors.blue,
                        size: 20,
                      ),
                      12.gap,
                      Expanded(
                        child: Text(
                          isEmployee
                              ? 'اسكان QR العميل عشان تشوف بيانات العربية'
                              : 'اسكان QR الموظف عشان تعرف مين دخلك',
                          style: context.bodyMedium.copyWith(
                            color: isEmployee ? Colors.green : Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              16.gap,
            ],

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
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.qr_code_scanner, color: Colors.white, size: 30),
                                            8.gap,
                                            Text(
                                              isEmployee ? 'QR العميل' : 'QR الموظف',
                                              style: context.bodySmall.copyWith(color: Colors.white),
                                              textAlign: TextAlign.center,
                                            ),
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
                color: _isScanning ? AppColors.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
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
                    _isScanning ? (isEmployee ? 'جاهز لسكان QR العميل' : 'جاهز لسكان QR الموظف') : 'معالجة...',
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
    );
  }
}
