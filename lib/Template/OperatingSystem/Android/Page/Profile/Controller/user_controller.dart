import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../../../Utils/Firebase/firebase_method.dart';
import '../../../../../Utils/Firebase/firebase_utils.dart';
import '../Model/user_model.dart';

class UserController extends GetxService {
  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;

  StreamSubscription<User?>? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _authSubscription = FirebaseUtils.auth.authStateChanges().listen((
      firebaseUser,
    ) async {
      if (firebaseUser != null) {
        await _loadUserProfile(firebaseUser.uid);
      } else {
        user.value = null;
      }
    });
  }

  Future<void> _loadUserProfile(String uid) async {
    isLoading.value = true;
    try {
      final doc = await FirebaseMethod.getDocument(
        ref: FirebaseUtils.userDoc(uid),
      );
      if (doc != null) user.value = UserModel.fromFirestore(doc);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshUser() async {
    final uid = FirebaseUtils.currentUid;
    if (uid != null) await _loadUserProfile(uid);
  }

  // Called after file upload — increments usedStorageMB atomically
  Future<void> incrementStorage(double fileSizeMB) async {
    final uid = FirebaseUtils.currentUid;
    if (uid == null) return;
    await FirebaseUtils.userDoc(
      uid,
    ).update({'usedStorageMB': (user.value?.usedStorageMB ?? 0) + fileSizeMB});
    await refreshUser();
  }

  // Called after file delete — decrements usedStorageMB
  Future<void> decrementStorage(double fileSizeMB) async {
    final uid = FirebaseUtils.currentUid;
    if (uid == null) return;
    final newValue = ((user.value?.usedStorageMB ?? 0) - fileSizeMB).clamp(
      0,
      double.infinity,
    );
    await FirebaseUtils.userDoc(uid).update({'usedStorageMB': newValue});
    await refreshUser();
  }

  bool get isLoggedIn => user.value != null;
  String get displayName => user.value?.name ?? '';
  String get displayEmail => user.value?.email ?? '';

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }
}
