import 'package:easy_localization/easy_localization.dart';
import 'package:must_invest/core/errors/app_exception.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';

class NoInternetException extends AppException {
  NoInternetException() : super('no internet connection');
}

class NoTokenException extends AppException {
  NoTokenException() : super("Auth token expected, none recieved.");
}

class AutoLoginException extends AppException {
  AutoLoginException() : super("No token is saved locally");
}

class LoginException extends AppException {
  final String code;

  LoginException(this.code) : super(code.tr());
}

class UnsupportedImageTypeException extends AppException {
  UnsupportedImageTypeException() : super("Unsupported Image Type.");
}

class UnauthenticatedException extends AppException {
  UnauthenticatedException() : super("User Unauthenticated");
}

class ServerException extends AppException {
  ServerException() : super(LocaleKeys.something_went_wrong.tr());
}
