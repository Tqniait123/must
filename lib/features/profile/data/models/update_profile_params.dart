import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';

class UpdateProfileParams {
  final String name;
  final int cityId;
  final PlatformFile? image;
  final PlatformFile? nationalIdFront;
  final PlatformFile? nationalIdBack;
  final PlatformFile? drivingLicenseFront;
  final PlatformFile? drivingLicenseBack;

  UpdateProfileParams({
    required this.name,
    required this.cityId,
    this.image,
    this.nationalIdFront,
    this.nationalIdBack,
    this.drivingLicenseFront,
    this.drivingLicenseBack,
  });

  /// Convert to FormData for multipart requests
  Future<FormData> toFormData() async {
    final Map<String, dynamic> fields = {};

    // Add required text fields
    fields['name'] = name;
    fields['city_id'] = cityId.toString();

    // Add optional file fields
    if (image != null) {
      fields['image'] = await _createMultipartFile(image!, 'image');
    }

    if (nationalIdFront != null) {
      fields['national_id_front'] = await _createMultipartFile(nationalIdFront!, 'national_id_front');
    }

    if (nationalIdBack != null) {
      fields['national_id_back'] = await _createMultipartFile(nationalIdBack!, 'national_id_back');
    }

    if (drivingLicenseFront != null) {
      fields['driving_license_front'] = await _createMultipartFile(drivingLicenseFront!, 'driving_license_front');
    }

    if (drivingLicenseBack != null) {
      fields['driving_license_back'] = await _createMultipartFile(drivingLicenseBack!, 'driving_license_back');
    }

    return FormData.fromMap(fields);
  }

  /// Helper method to create MultipartFile from PlatformFile using path
  Future<MultipartFile> _createMultipartFile(PlatformFile file, String fieldName) async {
    // Use fromPath if file has a path (mobile/desktop), otherwise use fromBytes (web)
    if (file.path != null) {
      return await MultipartFile.fromFile(
        file.path!,
        filename: file.name,
        contentType: _getContentType(file.extension),
      );
    } else {
      // Fallback to bytes for web platform
      return MultipartFile.fromBytes(file.bytes!, filename: file.name, contentType: _getContentType(file.extension));
    }
  }

  /// Get content type based on file extension
  MediaType? _getContentType(String? extension) {
    if (extension == null) return null;

    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      case 'bmp':
        return MediaType('image', 'bmp');
      case 'svg':
        return MediaType('image', 'svg+xml');
      default:
        return MediaType('image', 'jpeg'); // Default fallback
    }
  }

  /// Convert to Map (useful for logging or debugging)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'city_id': cityId,
      'image': image?.name,
      'national_id_front': nationalIdFront?.name,
      'national_id_back': nationalIdBack?.name,
      'driving_license_front': drivingLicenseFront?.name,
      'driving_license_back': drivingLicenseBack?.name,
    };
  }

  /// Copy with method for creating modified instances
  UpdateProfileParams copyWith({
    String? name,
    int? cityId,
    PlatformFile? image,
    PlatformFile? nationalIdFront,
    PlatformFile? nationalIdBack,
    PlatformFile? drivingLicenseFront,
    PlatformFile? drivingLicenseBack,
    bool clearImage = false,
    bool clearNationalIdFront = false,
    bool clearNationalIdBack = false,
    bool clearDrivingLicenseFront = false,
    bool clearDrivingLicenseBack = false,
  }) {
    return UpdateProfileParams(
      name: name ?? this.name,
      cityId: cityId ?? this.cityId,
      image: clearImage ? null : (image ?? this.image),
      nationalIdFront: clearNationalIdFront ? null : (nationalIdFront ?? this.nationalIdFront),
      nationalIdBack: clearNationalIdBack ? null : (nationalIdBack ?? this.nationalIdBack),
      drivingLicenseFront: clearDrivingLicenseFront ? null : (drivingLicenseFront ?? this.drivingLicenseFront),
      drivingLicenseBack: clearDrivingLicenseBack ? null : (drivingLicenseBack ?? this.drivingLicenseBack),
    );
  }

  /// Factory constructor to create from form data
  factory UpdateProfileParams.fromForm({
    required String name,
    required int cityId,
    PlatformFile? image,
    PlatformFile? nationalIdFront,
    PlatformFile? nationalIdBack,
    PlatformFile? drivingLicenseFront,
    PlatformFile? drivingLicenseBack,
  }) {
    return UpdateProfileParams(
      name: name,
      cityId: cityId,
      image: image,
      nationalIdFront: nationalIdFront,
      nationalIdBack: nationalIdBack,
      drivingLicenseFront: drivingLicenseFront,
      drivingLicenseBack: drivingLicenseBack,
    );
  }

  /// Validation method
  bool isValid() {
    return name.isNotEmpty && cityId > 0;
  }

  /// Get validation errors
  List<String> getValidationErrors() {
    final errors = <String>[];

    if (name.isEmpty) {
      errors.add('Name is required');
    }

    if (cityId <= 0) {
      errors.add('City is required');
    }

    return errors;
  }

  /// Check if any files are selected
  bool hasFiles() {
    return image != null ||
        nationalIdFront != null ||
        nationalIdBack != null ||
        drivingLicenseFront != null ||
        drivingLicenseBack != null;
  }

  /// Get selected files count
  int getFilesCount() {
    int count = 0;
    if (image != null) count++;
    if (nationalIdFront != null) count++;
    if (nationalIdBack != null) count++;
    if (drivingLicenseFront != null) count++;
    if (drivingLicenseBack != null) count++;
    return count;
  }

  /// Get total files size in bytes
  int getTotalFilesSize() {
    int totalSize = 0;
    if (image != null) totalSize += image!.size;
    if (nationalIdFront != null) totalSize += nationalIdFront!.size;
    if (nationalIdBack != null) totalSize += nationalIdBack!.size;
    if (drivingLicenseFront != null) totalSize += drivingLicenseFront!.size;
    if (drivingLicenseBack != null) totalSize += drivingLicenseBack!.size;
    return totalSize;
  }

  @override
  String toString() {
    return 'UpdateProfileParams{name: $name, cityId: $cityId, filesCount: ${getFilesCount()}}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UpdateProfileParams &&
        other.name == name &&
        other.cityId == cityId &&
        other.image?.name == image?.name &&
        other.nationalIdFront?.name == nationalIdFront?.name &&
        other.nationalIdBack?.name == nationalIdBack?.name &&
        other.drivingLicenseFront?.name == drivingLicenseFront?.name &&
        other.drivingLicenseBack?.name == drivingLicenseBack?.name;
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      cityId,
      image?.name,
      nationalIdFront?.name,
      nationalIdBack?.name,
      drivingLicenseFront?.name,
      drivingLicenseBack?.name,
    );
  }
}
