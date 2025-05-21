import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

class MyBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    if (kDebugMode) log('onCreate -- ${bloc.runtimeType}', name: 'Cubit');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (kDebugMode) {
      log('onChange -- ${bloc.runtimeType}, $change', name: 'Cubit');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      log('onError -- ${bloc.runtimeType}, $error', name: 'Cubit');
    }
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    if (kDebugMode) log('onClose -- ${bloc.runtimeType}', name: 'Cubit');
  }
}
