// core/network/network_info.dart
import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {

  NetworkInfoImpl(this.connectivity);
  final Connectivity connectivity;

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }
}
