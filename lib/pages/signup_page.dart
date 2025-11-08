import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:paws/themes/themes.dart';
import 'package:paws/widgets/buttons_input_widgets.dart';
import 'package:paws/widgets/new_user_onboard.dart';
import 'package:paws/auth/auth.dart'; // 🔹 import AuthService for Google sign in

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  final AuthService _authService = AuthService();

  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (passwordController.text != confirmPasswordController.text) {
      _showErrorDialog("Passwords don't match");
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(
          child: Lottie.asset('assets/lottie/loading.json', width: 100, height: 100),
        ),
      );

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenOnboarding', false);

      if (!context.mounted) return;
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OnboardingScreen(firebaseUID: FirebaseAuth.instance.currentUser?.uid),
        ),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      _showErrorDialog(_mapFirebaseError(e.code));
    }
  }

  Future<void> signUpWithGoogle() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(
          child: Lottie.asset('assets/lottie/loading.json', width: 100, height: 100),
        ),
      );

      await _authService.signInWithGoogle();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenOnboarding', false);

      if (!context.mounted) return;
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OnboardingScreen(firebaseUID: FirebaseAuth.instance.currentUser?.uid),
        ),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      _showErrorDialog(_mapFirebaseError(e.code));
    }
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'ERROR_ABORTED_BY_USER':
        return 'Sign in aborted by user.';
      default:
        return 'Signup failed. Please try again.';
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Signup Error'),
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

  Widget _buildSignUpForm() {
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
        const SizedBox(height: 20),
        LoginBtn1(
          controller: confirmPasswordController,
          hintText: 'Confirm Password',
          obscureText: !_confirmPasswordVisible,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Confirm password';
            return null;
          },
          icon: GestureDetector(
            onTap: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
            child: Icon(
              _confirmPasswordVisible ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(height: 20),
        CTAButton(text: 'Sign Up', onTap: signUp),
        const SizedBox(height: 20),

        // 🔹 Google Sign Up button (styled like CTAButton)
        CTAButton(
          text: 'Sign up with Google',
          onTap: signUpWithGoogle,
          icon: Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Image.asset(
              'assets/images/google_logo.png',
              height: 22,
              width: 22,
            ),
          ),
        ),

        const SizedBox(height: 20),
        const Divider(color: grey, indent: 20, endIndent: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Already have an account? '),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text(
                'Sign in now',
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
                      const SizedBox(height: 40),
                      Lottie.asset(
                        'assets/lottie/starting.json',
                        height: size.height * 0.25,
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        decoration: const BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.all(Radius.circular(40)),
                        ),
                        child: Form(key: _formKey, child: _buildSignUpForm()),
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
                            child: Form(key: _formKey, child: _buildSignUpForm()),
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
