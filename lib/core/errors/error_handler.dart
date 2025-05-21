import 'package:dio/dio.dart';
import 'package:must_invest/core/errors/app_error.dart';

class ErrorHandler {
  static AppError handle(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is FormatException) {
      return AppError(
        message: "فشل في تحليل الاستجابة",
        type: ErrorType.parsing,
      );
    } else if (error is DioException) {
      return AppError(message: error.message ?? '', type: ErrorType.network);
    } else if (error is DioException) {
      return AppError(message: error.message ?? '', type: ErrorType.api);
    } else {
      return AppError(message: "حدث خطأ غير متوقع", type: ErrorType.unknown);
    }
  }

  static AppError _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return AppError(message: "انتهت مهلة الاتصال", type: ErrorType.network);
      case DioExceptionType.sendTimeout:
        return AppError(
          message: "انتهت مهلة إرسال الطلب",
          type: ErrorType.network,
        );
      case DioExceptionType.receiveTimeout:
        return AppError(
          message: "انتهت مهلة استقبال الاستجابة",
          type: ErrorType.network,
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        return AppError(
          message: "تم تلقي رمز حالة غير صالح: $statusCode",
          type: ErrorType.api,
        );
      case DioExceptionType.cancel:
        return AppError(message: "تم إلغاء الطلب", type: ErrorType.network);
      case DioExceptionType.unknown:
        return AppError(
          message: "خطأ غير متوقع: ${error.message}",
          type: ErrorType.network,
        );
      default:
        return AppError(
          message: "خطأ غير معروف من Dio",
          type: ErrorType.network,
        );
    }
  }
}
