import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../OperatingSystem/Android/Page/Welcome/Model/user_model.dart';
import '../Firebase/firebase_method.dart';
import '../Firebase/firebase_utils.dart';

// 📁 lib/Template/Utils/Services/user_controller.dart
//
// Global controller that holds the currently logged-in user.
// Listens to Firebase Auth state changes and keeps the Firestore
// user profile in sync. All screens access the current user from here.

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
      if (doc != null) {
        user.value = UserModel.fromFirestore(doc);
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Call after updating profile fields to refresh local state.
  Future<void> refreshUser() async {
    final uid = FirebaseUtils.currentUid;
    if (uid != null) await _loadUserProfile(uid);
  }

  /// Convenience getters
  bool get isLoggedIn => user.value != null;
  String get displayName => user.value?.name ?? '';
  String get displayEmail => user.value?.email ?? '';

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }
}
