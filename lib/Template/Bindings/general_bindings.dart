import 'package:get/get.dart';
import '../Utils/Services/server_notifier.dart';
import '../Utils/Services/user_controller.dart';

// 📁 lib/Template/Bindings/general_bindings.dart
//
// Registers all app-wide GetX services at startup.
// Add any new global service here so it's available
// throughout the entire app lifecycle.

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    // Network / server status
    Get.put<ServerNotifier>(ServerNotifier(), permanent: true);

    // Current user session
    Get.put<UserController>(UserController(), permanent: true);
  }
}
