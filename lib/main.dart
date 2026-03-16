import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Template/Commons/Styles/style.dart';
import 'firebase_options.dart';
import 'Template/Bindings/general_bindings.dart';
import 'Template/Utils/Routes/routes.dart';
import 'Template/Utils/Routes/main_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Document Management',
      debugShowCheckedModeBanner: false,
      theme: AppStyle.lightTheme,
      darkTheme: AppStyle.darkTheme,
      themeMode: ThemeMode.system,
      initialBinding: GeneralBindings(),
      initialRoute: MainRoutes.signIn,
      getPages: AppRoutes.pages,
    );
  }
}
