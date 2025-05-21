import 'package:dio/dio.dart';

extension StringToAuthorizationOptions on String {
  Options toAuthorizationOptions() {
    return Options(headers: {'Authorization': 'Bearer $this'});
  }
}
