import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_themes.dart';
import 'providers/auth_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/user_provider.dart';
import 'providers/vendor_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/locale_provider.dart';
import 'views/root_wrapper.dart';
import 'views/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Note: Firebase initialization will be added once configuration is provided.

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => VendorProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PLANIFY',
      theme: AppThemes.lightTheme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
