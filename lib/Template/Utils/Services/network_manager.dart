import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../Exceptions/exceptions.dart';

class NetworkManager extends GetxService {
  static NetworkManager get to => Get.find<NetworkManager>();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final RxBool isConnected = true.obs;
  final Rx<ConnectivityResult> connectionType = ConnectivityResult.none.obs;

  bool get isWifi => connectionType.value == ConnectivityResult.wifi;

  bool get isMobile =>
      connectionType.value == ConnectivityResult.mobile ||
      connectionType.value == ConnectivityResult.mobile;

  bool get isEthernet => connectionType.value == ConnectivityResult.ethernet;

  bool get isOffline =>
      connectionType.value == ConnectivityResult.none || !isConnected.value;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnectivity();
    _listenToConnectivityChanges();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateState(results);
    } catch (_) {
      isConnected.value = false;
      connectionType.value = ConnectivityResult.none;
    }
  }

  void _listenToConnectivityChanges() {
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateState,
      onError: (_) {
        isConnected.value = false;
        connectionType.value = ConnectivityResult.none;
      },
    );
  }

  // ─── State update ─────────────────────────────────────────────────────────

  void _updateState(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.wifi)) {
      connectionType.value = ConnectivityResult.wifi;
      isConnected.value = true;
    } else if (results.contains(ConnectivityResult.ethernet)) {
      connectionType.value = ConnectivityResult.ethernet;
      isConnected.value = true;
    } else if (results.contains(ConnectivityResult.mobile)) {
      connectionType.value = ConnectivityResult.mobile;
      isConnected.value = true;
    } else {
      connectionType.value = ConnectivityResult.none;
      isConnected.value = false;
    }
  }

  // ─── Guard method ─────────────────────────────────────────────────────────

  void checkBeforeRequest() {
    if (isOffline) throw const NetworkException();
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
      default:
        return 'No Connection';
    }
  }
}
