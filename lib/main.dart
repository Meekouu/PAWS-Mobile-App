import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:paws/pages/intro_page.dart';
import 'package:paws/pages/login_page.dart';
import 'package:paws/pages/profile_page.dart';
import 'package:paws/pages/signup_page.dart';
import 'package:paws/pages/home_page.dart';
import 'package:paws/pages/pet_manager.dart';
import 'package:paws/themes/themes.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Activate App Check: Play Integrity for release, Debug provider for dev
  await FirebaseAppCheck.instance.activate(
    androidProvider: kReleaseMode ? AndroidProvider.playIntegrity : AndroidProvider.debug,
    appleProvider: AppleProvider.deviceCheck,
  );
  
  // Initialize notifications (but don't block on refresh)
  await NotificationService().initialize();
  
  // Schedule refresh asynchronously after app starts (non-blocking)
  // This prevents black screen on startup if user isn't logged in yet
  Future.delayed(const Duration(seconds: 2), () {
    NotificationService().refreshSchedules().catchError((e) {
      debugPrint('Background notification refresh failed: $e');
    });
  });
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('is_first_launch') ?? true;
  final currentUser = FirebaseAuth.instance.currentUser;

  if (isFirstLaunch) {
    await prefs.setBool('is_first_launch', false);
  }

  // If user is already signed in, go straight to HomePage
  final isLoggedIn = currentUser != null;
  runApp(MyApp(showIntro: isFirstLaunch && !isLoggedIn, isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool showIntro;
  final bool isLoggedIn;
  const MyApp({super.key, required this.showIntro, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      // Decide initial screen based on auth state and first-launch flag
      home: isLoggedIn
          ? PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) async {
                if (didPop) return;
                final shouldExit = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text("Exit App"),
                    content: const Text("Do you really want to exit?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: const Text("Exit"),
                      ),
                    ],
                  ),
                );
                if (shouldExit ?? false) {
                  SystemNavigator.pop();
                }
              },
              child: HomePage(),
            )
          : (showIntro ? const IntroPage() : const LoginPage()),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/intro':
            return MaterialPageRoute(builder: (_) => const IntroPage());
          case '/auth':
            return MaterialPageRoute(builder: (_) => const LoginPage());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());
          case '/signup':
            return MaterialPageRoute(builder: (_) => const SignUpPage());
          case '/home':
            return MaterialPageRoute(
              builder: (context) => PopScope(
                canPop: false, // disables default back navigation
                onPopInvokedWithResult: (didPop, result) async {
                  if (didPop) return; // if system already handled it, do nothing

                  final shouldExit = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text("Exit App"),
                      content: const Text("Do you really want to exit?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
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