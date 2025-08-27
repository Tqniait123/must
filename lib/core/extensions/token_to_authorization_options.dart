import 'package:dio/dio.dart';

extension StringToAuthorizationOptions on String {
  Options toAuthorizationOptions() {
    if (isEmpty) {
      return Options();
    }
    return Options(headers: {'Authorization': 'Bearer $this'});
  }
}
