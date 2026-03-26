import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'Template/Utils/Constant/colors.dart';
import 'Template/Utils/Constant/texts.dart';
import 'Template/Utils/Themes/theme.dart';
import 'firebase_options.dart';
import 'Template/Bindings/general_bindings.dart';
import 'Template/Utils/Firebase/firebase_utils.dart';
import 'Template/Utils/Routes/routes.dart';
import 'Template/Utils/Routes/main_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Make status bar and system nav bar transparent so the app
  // background color shows through seamlessly on all screens.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  // Check internet before loading the app
  final hasInternet = await _checkInternet();
  if (!hasInternet) {
    runApp(const _NoInternetApp());
    return;
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // v7: must initialize once before any sign-in calls
  await GoogleSignIn.instance.initialize();

  runApp(const App());
}

// Quick internet check via DNS lookup
Future<bool> _checkInternet() async {
  try {
    final result = await InternetAddress.lookup(
      'google.com',
    ).timeout(const Duration(seconds: 5));
    return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
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
    );
  }
}

// ─── No internet app ──────────────────────────────────────────────────────────

class _NoInternetApp extends StatelessWidget {
  const _NoInternetApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: _NoInternetScreen(),
    );
  }
}

class _NoInternetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 72,
                color: AppColors.textHint,
              ),
              const SizedBox(height: 24),
              Text(
                'No Internet Connection',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Scrivener requires an internet connection to work. '
                'Please check your connection and try again.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => SystemNavigator.pop(),
                  child: const Text('Close App'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
