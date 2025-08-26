import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:paws/widgets/loading_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:paws/auth/auth.dart';
import 'package:paws/pages/home_page.dart';
import 'package:paws/pages/signup_page.dart';
import 'package:paws/themes/themes.dart';
import 'package:paws/widgets/new_user_onboard.dart';
import 'package:paws/widgets/buttons_input_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _passwordVisible = false;

  final AuthService _authService = AuthService();

  Future<void> signIn() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      showLoadingDialog(context);

      await _authService.signInWithEmail(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      await _handlePostLogin();
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      _showErrorDialog(_mapFirebaseError(e.code));
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      showLoadingDialog(context);

      await _authService.signInWithGoogle();

      await _handlePostLogin();
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      _showErrorDialog(_mapFirebaseError(e.code));
    }
  }

  Future<void> _handlePostLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    final nextPage = hasSeenOnboarding
        ? HomePage()
        : OnboardingScreen(firebaseUID: FirebaseAuth.instance.currentUser?.uid);

    if (!context.mounted) return;
    Navigator.pop(context);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => nextPage));
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'ERROR_ABORTED_BY_USER':
        return 'Sign in aborted by user.';
      default:
        return 'Login failed. Please try again.';
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Login Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'PAWS',
          style: GoogleFonts.notoSerifDisplay(
            fontSize: 36,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 20),
        LoginBtn1(
          controller: emailController,
          hintText: 'happypaws@paws.com',
          obscureText: false,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Enter email';
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return 'Invalid email format';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        LoginBtn1(
          controller: passwordController,
          hintText: 'Password',
          obscureText: !_passwordVisible,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Enter password';
            if (value.length < 6) return 'Minimum 6 characters';
            return null;
          },
          icon: GestureDetector(
            onTap: () => setState(() => _passwordVisible = !_passwordVisible),
            child: Icon(
              _passwordVisible ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(height: 10),
        CTAButton(text: 'Sign In', onTap: signIn),
        const SizedBox(height: 20),

        // 🔹 Google Sign-In Button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: signInWithGoogle,
          icon: Image.asset(
            'assets/images/google_logo.png', // 🔹 Add this asset (Google logo)
            height: 24,
            width: 24,
          ),
          label: const Text("Sign in with Google"),
        ),

        const SizedBox(height: 20),
        const Text('Forgot Login Details? Get Help Logging in'),
        const Divider(color: grey, indent: 20, endIndent: 20),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Don't have an account? "),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignUpPage()),
              ),
              child: const Text(
                'Signup now',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: secondaryColor,
      body: SafeArea(
        child: Center(
          child: isPortrait
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Lottie.asset(
                        'assets/lottie/starting.json',
                        height: size.height * 0.25,
                        fit: BoxFit.contain,
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: const BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.all(Radius.circular(40)),
                        ),
                        child: Form(key: _formKey, child: _buildLoginForm()),
                      ),
                    ],
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Lottie.asset(
                          'assets/lottie/starting.json',
                          height: size.height * 0.5,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            bottomLeft: Radius.circular(40),
                          ),
                        ),
                        child: Center(
                          child: SingleChildScrollView(
                            child: Form(key: _formKey, child: _buildLoginForm()),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
