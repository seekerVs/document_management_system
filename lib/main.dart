import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'Template/Utils/Constant/texts.dart';
import 'Template/Utils/Themes/theme.dart';
import 'firebase_options.dart';
import 'Template/Bindings/general_bindings.dart';
import 'Template/Utils/Firebase/firebase_utils.dart';
import 'Template/Utils/Firebase/notification_service.dart';
import 'Template/Utils/Routes/routes.dart';
import 'Template/Utils/Routes/main_routes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'Template/Commons/Widgets/no_internet_screen.dart';
import 'Template/Utils/Services/network_manager.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final notificationService = Get.put(NotificationService());
  await notificationService.init();

  // v7: must initialize once before any sign-in calls
  await GoogleSignIn.instance.initialize();

  // Inject NetworkManager globally before the app boots
  final networkManager = Get.put(NetworkManager(), permanent: true);
  // Force a ping to Google to guarantee accurate 'hasInternetAccess' state
  await networkManager.verifyInternetAccess();

  runApp(const App());
}

// ─── Main app ─────────────────────────────────────────────────────────────────

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppText.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      initialBinding: GeneralBindings(),
      initialRoute: FirebaseUtils.auth.currentUser != null
          ? MainRoutes.home
          : MainRoutes.signIn,
      getPages: AppRoutes.pages,
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            Obx(() {
              final hasInternet = NetworkManager.to.hasInternetAccess.value;
              if (!hasInternet) {
                return const NoInternetScreen();
              }
              return const SizedBox.shrink();
            }),
          ],
        );
      },
    );
  }
}
