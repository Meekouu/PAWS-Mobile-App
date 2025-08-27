import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paws/pages/intro_page.dart';
import 'package:paws/pages/login_page.dart';
import 'package:paws/pages/profile_page.dart';
import 'package:paws/pages/signup_page.dart';
import 'package:paws/pages/home_page.dart';
import 'package:paws/pages/pet_manager.dart';
import 'package:paws/themes/themes.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        scaffoldBackgroundColor: backgroundColor,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      home: showIntro ? const IntroPage() : const LoginPage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/intro':
            return MaterialPageRoute(builder: (_) => const IntroPage());
          case '/auth':
            return MaterialPageRoute(builder: (_) => const LoginPage());
          case '/signup':
            return MaterialPageRoute(builder: (_) => const SignUpPage());
          case '/home':
            return MaterialPageRoute(
              builder: (_) => PopScope(
                canPop: false, // disables default back navigation
                onPopInvoked: (didPop) async {
                  if (didPop) return; // if system already handled it, do nothing

                  final shouldExit = await showDialog<bool>(
                    context: _,
                    builder: (context) => AlertDialog(
                      title: const Text("Exit App"),
                      content: const Text("Do you really want to exit?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Exit"),
                        ),
                      ],
                    ),
                  );

                  if (shouldExit ?? false) {
                    SystemNavigator.pop(); // closes the app
                  }
                },
                child: HomePage(),
              ),
            );
          case '/profile':
            return MaterialPageRoute(builder: (_) => ProfilePage());
          case '/pets':
            return MaterialPageRoute(builder: (_) => PetManager());
          default:
            return MaterialPageRoute(builder: (_) => const LoginPage());
        }
      },
    );
  }
}

