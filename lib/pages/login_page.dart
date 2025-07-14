import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paws/pages/home_page.dart';
import 'package:paws/pages/signup_page.dart';
import 'package:paws/themes/themes.dart';
import 'package:paws/widgets/cta_buton.dart';
import 'package:paws/widgets/new_user_onboard.dart'; 
import 'package:paws/widgets/show_message.dart';
import 'package:paws/widgets/text_button_login.dart';
import 'package:shared_preferences/shared_preferences.dart';  

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _passwordVisible = false;

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!context.mounted) return;

      Navigator.pop(context); 

      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

      if (hasSeenOnboarding) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OnboardingPage1(
              onFinish: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('hasSeenOnboarding', true);

                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                }
              },
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);

      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'The email address is badly formatted.';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled.';
          break;
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid login credentials.';
          break;
        default:
          errorMessage = 'Login failed. Please try again.';
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
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
        const SizedBox(height: 10),
        LoginBtn1(
          controller: emailController,
          hintText: 'happypaws@paws.com',
          obscureText: false,
          validator: emailValidator,
        ),
        const SizedBox(height: 20),
        LoginBtn1(
          controller: passwordController,
          hintText: 'Password',
          obscureText: !_passwordVisible,  // hide password when false
          validator: passwordValidator,
          icon: GestureDetector(
            onTap: () {
              setState(() {
                _passwordVisible = !_passwordVisible; // toggle visibility
              });
            },
            child: Icon(
              _passwordVisible ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(height: 20),
        CTAButton(
          text: 'Sign In',
          onTap: signIn,
        ),
        const SizedBox(height: 30),
        const Text('Forgot Login Details? Get Help Logging in'),
        const Divider(
          color: grey,
          indent: 20,
          endIndent: 20,
          thickness: 1,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Don\'t Have an account? '),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SignUpPage(),
                  ),
                );
              },
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
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      backgroundColor: white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: isPortrait
                ? Column(
                    children: [
                      const SizedBox(height: 75),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 30, 10, 20),
                        child: Image.asset(
                          'assets/images/paw-placeholder.png',
                          height: screenHeight * 0.3,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Container(
                        height: screenHeight * 0.5,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                        ),
                        child: Center(child: _buildLoginForm()),
                      ),
                    ],
                  )
                : SizedBox(
                    height: screenHeight,
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 10),
                                Expanded(
                                  child: Image.asset(
                                    'assets/images/paw-placeholder.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40),
                              ),
                              color: white,
                            ),
                            child: Center(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: _buildLoginForm(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
