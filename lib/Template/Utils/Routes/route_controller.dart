import 'package:get/get.dart';
import '../Firebase/firebase_utils.dart';
import 'main_routes.dart';

// 📁 lib/Template/Utils/Routes/route_controller.dart
//
// Decides where to send the user on app launch:
// - Logged in  → Home
// - Not logged in → Sign In

class RouteController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _redirect();
  }

  void _redirect() {
    if (FirebaseUtils.isLoggedIn) {
      Get.offAllNamed(MainRoutes.home);
    } else {
      Get.offAllNamed(MainRoutes.signIn);
    }
  }
}
