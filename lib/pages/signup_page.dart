import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paws/themes/themes.dart';
import 'package:paws/widgets/cta_buton.dart';
import 'package:paws/widgets/show_message.dart';
import 'package:paws/widgets/text_button_login.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  Future<void> signUp() async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    if (passwordController.text != confirmPasswordController.text) {
      Navigator.pop(context);
      showMessage('Signup Error', 'Passwords don\'t match', context);
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: confirmPasswordController.text,
      );

      Navigator.pop(context);
      showMessage('Success', 'Account created successfully', context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);

      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'This email is already in use.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid.';
          break;
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        default:
          errorMessage = 'An unexpected error occurred.';
      }

      showMessage('Signup Error', errorMessage, context);
    }
  }

  Widget _buildSignUpForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Paws',
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
        ),
        const SizedBox(height: 20),
        LoginBtn1(
          controller: passwordController,
          hintText: 'Password',
          obscureText: !_passwordVisible,
          icon: GestureDetector(
            onTap: () {
              setState(() {
                _passwordVisible = !_passwordVisible;
              });
            },
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
          icon: GestureDetector(
            onTap: () {
              setState(() {
                _confirmPasswordVisible = !_confirmPasswordVisible;
              });
            },
            child: Icon(
              _confirmPasswordVisible ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(height: 20),
        CTAButton(
          text: 'Signup',
          onTap: signUp,
        ),
        const SizedBox(height: 20),
        const Divider(
          color: grey,
          indent: 20,
          endIndent: 20,
          thickness: 1,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Have an account? '),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Signin now',
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: isPortrait
              ? Column(
                  children: [
                    const SizedBox(height: 50),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 30, 10, 20),
                      child: Image.asset(
                        'assets/images/paw-placeholder.png',
                        height: screenHeight * 0.3,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Container(
                      height: screenHeight * 0.55,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                      child: Center(child: _buildSignUpForm()),
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
                              child: _buildSignUpForm(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}