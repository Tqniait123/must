import 'dart:convert';
import 'dart:developer';

/// نوع QR Code
enum QrType {
  user('user'), // QR بتاع اليوزر
  employee('employee'); // QR بتاع الموظف

  const QrType(this.value);
  final String value;
}

/// بيانات اليوزر للـ QR
class UserQrData {
  final String userId;
  final String userName;
  final String carId;
  final String carName;
  final String metalPlate;
  final String? carColor;

  const UserQrData({
    required this.userId,
    required this.userName,
    required this.carId,
    required this.carName,
    required this.metalPlate,
    this.carColor,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': 'user',
      'uid': userId,
      'un': userName,
      'cid': carId,
      'cn': carName,
      'mp': metalPlate,
      if (carColor != null) 'cc': carColor,
    };
  }

  factory UserQrData.fromJson(Map<String, dynamic> json) {
    return UserQrData(
      userId: json['uid'] ?? '',
      userName: json['un'] ?? '',
      carId: json['cid'] ?? '',
      carName: json['cn'] ?? '',
      metalPlate: json['mp'] ?? '',
      carColor: json['cc'],
    );
  }
}

/// بيانات الموظف للـ QR
class EmployeeQrData {
  final String employeeId;
  final String employeeName;
  final String parkingLocation;
  final String shiftTime;

  const EmployeeQrData({
    required this.employeeId,
    required this.employeeName,
    required this.parkingLocation,
    required this.shiftTime,
  });

  Map<String, dynamic> toJson() {
    return {'type': 'employee', 'eid': employeeId, 'en': employeeName, 'pl': parkingLocation, 'st': shiftTime};
  }

  factory EmployeeQrData.fromJson(Map<String, dynamic> json) {
    return EmployeeQrData(
      employeeId: json['eid'] ?? '',
      employeeName: json['en'] ?? '',
      parkingLocation: json['pl'] ?? '',
      shiftTime: json['st'] ?? '',
    );
  }
}

/// نتيجة فك التشفير
class QrScanResult {
  final bool isValid;
  final QrType? type;
  final UserQrData? userData;
  final EmployeeQrData? employeeData;
  final String? error;

  const QrScanResult({required this.isValid, this.type, this.userData, this.employeeData, this.error});

  factory QrScanResult.userSuccess(UserQrData data) {
    return QrScanResult(isValid: true, type: QrType.user, userData: data);
  }

  factory QrScanResult.employeeSuccess(EmployeeQrData data) {
    return QrScanResult(isValid: true, type: QrType.employee, employeeData: data);
  }

  factory QrScanResult.error(String error) {
    return QrScanResult(isValid: false, error: error);
  }
}

/// خدمة QR للموظف واليوزر
class ParkingQrService {
  static const String _prefix = 'PARKING:';

  // ========== للاستخدام في تطبيق اليوزر ==========

  /// اليوزر يولد QR عشان الموظف يسكانه
  static String generateUserQr({
    required String userId,
    required String userName,
    required String carId,
    required String carName,
    required String metalPlate,
    String? carColor,
  }) {
    try {
      final data = UserQrData(
        userId: userId,
        userName: userName,
        carId: carId,
        carName: carName,
        metalPlate: metalPlate,
        carColor: carColor,
      );

      final jsonString = jsonEncode(data.toJson());
      final base64Data = base64Encode(utf8.encode(jsonString));

      return '$_prefix$base64Data';
    } catch (e) {
      log('خطأ في إنشاء QR اليوزر: $e');
      throw Exception('فشل في إنشاء QR Code');
    }
  }

  /// اليوزر يسكان QR الموظف عشان يعرف مين دخله
  static QrScanResult scanEmployeeQr(String qrString) {
    final result = _decodeQr(qrString);

    if (!result.isValid) return result;

    if (result.type == QrType.employee) {
      log('اليوزر سكان موظف: ${result.employeeData!.employeeName}');
      log('مكان الركن: ${result.employeeData!.parkingLocation}');
      return result;
    } else {
      return QrScanResult.error('هذا QR خاص باليوزر، مش الموظف');
    }
  }

  // ========== للاستخدام في تطبيق الموظف ==========

  /// الموظف يولد QR عشان اليوزر يسكانه
  static String generateEmployeeQr({
    required String employeeId,
    required String employeeName,
    required String parkingLocation,
    required String shiftTime,
  }) {
    try {
      final data = EmployeeQrData(
        employeeId: employeeId,
        employeeName: employeeName,
        parkingLocation: parkingLocation,
        shiftTime: shiftTime,
      );

      final jsonString = jsonEncode(data.toJson());
      final base64Data = base64Encode(utf8.encode(jsonString));

      return '$_prefix$base64Data';
    } catch (e) {
      log('خطأ في إنشاء QR الموظف: $e');
      throw Exception('فشل في إنشاء QR Code');
    }
  }

  /// الموظف يسكان QR اليوزر عشان يعرف بيانات العربية
  static QrScanResult scanUserQr(String qrString) {
    final result = _decodeQr(qrString);

    if (!result.isValid) return result;

    if (result.type == QrType.user) {
      log('الموظف سكان عربية: ${result.userData!.carName}');
      log('صاحب العربية: ${result.userData!.userName}');
      log('رقم اللوحة: ${result.userData!.metalPlate}');
      return result;
    } else {
      return QrScanResult.error('هذا QR خاص بالموظف، مش اليوزر');
    }
  }

  // ========== وظائف مساعدة ==========

  /// فك تشفير أي QR
  static QrScanResult _decodeQr(String qrString) {
    try {
      if (!qrString.startsWith(_prefix)) {
        return QrScanResult.error('QR Code غير صحيح');
      }

      String base64Data = qrString.substring(_prefix.length);

      // Clean the Base64 string
      base64Data = base64Data.replaceAll(RegExp(r'[^a-zA-Z0-9+/=]'), '');

      // Add proper padding
      final paddingLength = (4 - (base64Data.length % 4)) % 4;
      base64Data = base64Data.padRight(base64Data.length + paddingLength, '=');

      final jsonBytes = base64.decode(base64Data);
      final jsonString = utf8.decode(jsonBytes);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      // تحديد النوع وفك التشفير
      final type = jsonData['type'] as String?;

      if (type == 'user') {
        final userData = UserQrData.fromJson(jsonData);
        return QrScanResult.userSuccess(userData);
      } else if (type == 'employee') {
        final employeeData = EmployeeQrData.fromJson(jsonData);
        return QrScanResult.employeeSuccess(employeeData);
      } else {
        return QrScanResult.error('نوع QR غير معروف');
      }
    } catch (e) {
      log('خطأ في فك التشفير: $e');
      return QrScanResult.error('فشل في قراءة QR Code');
    }
  }

  /// استخراج ID بسرعة بدون فحص كامل
  static String? extractUserId(String qrString) {
    try {
      if (!qrString.startsWith(_prefix)) return null;

      final base64Data = qrString.substring(_prefix.length);
      final jsonBytes = base64Decode(base64Data);
      final jsonString = utf8.decode(jsonBytes);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      return jsonData['uid'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// استخراج ID الموظف بسرعة
  static String? extractEmployeeId(String qrString) {
    try {
      if (!qrString.startsWith(_prefix)) return null;

      final base64Data = qrString.substring(_prefix.length);
      final jsonBytes = base64Decode(base64Data);
      final jsonString = utf8.decode(jsonBytes);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      return jsonData['eid'] as String?;
    } catch (e) {
      return null;
    }
  }
}
