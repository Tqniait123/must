class AppException<T> implements Exception {
  final String message;

  AppException(this.message);

  @override

  String toString() {
    // return "${T.runtimeType} Exception: $message";
    return message;
  }
}
