import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<ConnectivityResult> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;
  NetworkInfoImpl(this._connectivity);

  @override
  Future<ConnectivityResult> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    if (results.isNotEmpty) {
      return results
          .first; // Return the first result or decide how to handle the list
    }
    throw Exception("No connectivity results available");
  }
}
