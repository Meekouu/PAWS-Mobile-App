import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paws/pages/intro_page.dart';
import 'package:paws/pages/login_page.dart';
import 'package:paws/pages/signup_page.dart';
import 'package:paws/pages/home_page.dart';
import 'package:paws/themes/themes.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:paws/auth/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('is_first_launch') ?? true;

  if (isFirstLaunch) {
    await prefs.setBool('is_first_launch', false);
  }

  runApp(MyApp(showIntro: isFirstLaunch));
}

class MyApp extends StatelessWidget {
  final bool showIntro;
  const MyApp({super.key, required this.showIntro});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: white,
        brightness: Brightness.light,
        useMaterial3: true,
      ),

      initialRoute: showIntro ? '/intro' : '/auth',

      routes: {
        '/intro': (context) => const IntroPage(),
        '/auth': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}
