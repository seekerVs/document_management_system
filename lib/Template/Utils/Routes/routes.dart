import 'package:get/get.dart';
import '../../OperatingSystem/Android/Page/SignIn/Controller/sign_in_controller.dart';
import '../../OperatingSystem/Android/Page/SignIn/Controller/sign_up_controller.dart';
import '../../OperatingSystem/Android/Page/SignIn/View/sign_in_view.dart';
import '../../OperatingSystem/Android/Page/SignIn/View/sign_up_view.dart';
import 'main_routes.dart';

// 📁 lib/Template/Utils/Routes/routes.dart
// Add new pages here as features are built.

class AppRoutes {
  AppRoutes._();

  static final List<GetPage> pages = [
    // Auth
    GetPage(
      name: MainRoutes.signIn,
      page: () => const SignInView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SignInController());
      }),
    ),
    GetPage(
      name: MainRoutes.signUp,
      page: () => const SignUpView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SignUpController());
      }),
    ),

    // Home, Documents, Signature etc. added as features are built
  ];
}
