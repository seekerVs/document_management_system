import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

// 📁 lib/Template/Utils/Services/server_notifier.dart
//
// Monitors Firestore connectivity and exposes an observable
// isOnline flag. Widgets can react to connectivity changes
// to show offline banners or disable actions.

class ServerNotifier extends GetxService {
  final RxBool isOnline = true.obs;
  StreamSubscription? _subscription;

  @override
  void onInit() {
    super.onInit();
    _listenToConnectivity();
  }

  void _listenToConnectivity() {
    _subscription = FirebaseFirestore.instance
        .collection('_heartbeat')
        .snapshots()
        .listen(
          (_) => isOnline.value = true,
          onError: (_) => isOnline.value = false,
        );
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
