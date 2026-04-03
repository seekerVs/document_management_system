import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../Exceptions/exceptions.dart';

class NetworkManager extends GetxService {
  static NetworkManager get to => Get.find<NetworkManager>();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final RxBool isConnected = true.obs;
  final RxBool hasInternetAccess = true.obs;
  final Rx<ConnectivityResult> connectionType = ConnectivityResult.none.obs;

  Timer? _verificationTimer;

  bool get isWifi => connectionType.value == ConnectivityResult.wifi;

  bool get isMobile => connectionType.value == ConnectivityResult.mobile;

  bool get isEthernet => connectionType.value == ConnectivityResult.ethernet;

  bool get isVpn => connectionType.value == ConnectivityResult.vpn;

  bool get isBluetooth => connectionType.value == ConnectivityResult.bluetooth;

  bool get isOffline =>
      connectionType.value == ConnectivityResult.none || !isConnected.value;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnectivity();
    _listenToConnectivityChanges();
    _startPeriodicVerification();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    _verificationTimer?.cancel();
    super.onClose();
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateState(results);
    } catch (_) {
      isConnected.value = false;
      connectionType.value = ConnectivityResult.none;
      hasInternetAccess.value = false;
    }
  }

  void _listenToConnectivityChanges() {
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateState,
      onError: (_) {
        isConnected.value = false;
        connectionType.value = ConnectivityResult.none;
        hasInternetAccess.value = false;
      },
    );
  }

  void _updateState(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      connectionType.value = ConnectivityResult.none;
      isConnected.value = false;
      hasInternetAccess.value = false;
      return;
    }

    // Prioritize results
    if (results.contains(ConnectivityResult.ethernet)) {
      connectionType.value = ConnectivityResult.ethernet;
    } else if (results.contains(ConnectivityResult.wifi)) {
      connectionType.value = ConnectivityResult.wifi;
    } else if (results.contains(ConnectivityResult.vpn)) {
      connectionType.value = ConnectivityResult.vpn;
    } else if (results.contains(ConnectivityResult.mobile)) {
      connectionType.value = ConnectivityResult.mobile;
    } else if (results.contains(ConnectivityResult.bluetooth)) {
      connectionType.value = ConnectivityResult.bluetooth;
    } else {
      connectionType.value = results.first;
    }

    isConnected.value = connectionType.value != ConnectivityResult.none;

    // Trigger internet verification when connection is established
    if (isConnected.value) {
      verifyInternetAccess();
    } else {
      hasInternetAccess.value = false;
    }
  }

  /// Robust internet check using Google's connectivity-check endpoint.
  /// Returns HTTP 204 only when there is real WAN (internet) access.
  /// Carrier networks without data plans and captive portals cannot
  /// fake this response, unlike raw Socket or DNS lookups.
  Future<bool> verifyInternetAccess() async {
    try {
      final response = await http
          .get(Uri.parse('http://connectivitycheck.gstatic.com/generate_204'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 204) {
        hasInternetAccess.value = true;

        // If we succeeded but our connection type says none, override it
        if (connectionType.value == ConnectivityResult.none) {
          isConnected.value = true;
          connectionType.value = ConnectivityResult.wifi;
        }
        return true;
      }

      // Any other status (302 redirect from captive portal, etc.)
      hasInternetAccess.value = false;
      return false;
    } catch (_) {
      hasInternetAccess.value = false;
      return false;
    }
  }

  void _startPeriodicVerification() {
    _verificationTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (isConnected.value) {
        verifyInternetAccess();
      }
    });
  }

  void checkBeforeRequest() {
    if (isOffline || !hasInternetAccess.value) throw const NetworkException();
  }

  String? mobileDataWarning({
    required double fileSizeMB,
    double warnAboveMB = 10,
  }) {
    if (!isMobile) return null;
    if (fileSizeMB <= warnAboveMB) return null;
    return 'You are on mobile data. Uploading this file '
        '(${fileSizeMB.toStringAsFixed(1)} MB) may use significant data.';
  }

  String get connectionLabel {
    switch (connectionType.value) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      default:
        return 'No Connection';
    }
  }
}
