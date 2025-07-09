import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paws/auth/auth.dart';
import 'package:paws/widgets/cta_buton.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: screenHeight * 0.15), // avoid content hidden behind bottom bar
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.05), // 5% of screen height
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.1), // 10% left padding
                  child: Text(
                    'PAWS',
                    style: GoogleFonts.notoSerifDisplay(
                      fontSize: screenWidth * 0.08, // dynamic font size
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            // Removed Terms & Conditions from here
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.1,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CTAButton(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AuthPage()),
              ),
              text: 'Get Started',
            ),
            SizedBox(height: screenHeight * 0.01),
            const Text('Terms & Conditions apply'),
          ],
        ),
      ),
    );
  }
}
