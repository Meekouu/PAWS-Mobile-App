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

    final titleFontSize = screenWidth * 0.08;

    final horizontalPadding = screenWidth * 0.1;

    final topPadding = screenHeight * 0.05;
    final spaceBetweenTextAndLogo = screenHeight * 0.25;
    final bottomSafeArea = screenHeight * 0.15;
    final bottomPadding = screenHeight * 0.02;
    final buttonHeightEstimate = 50.0;

    final availableHeightForLogo = screenHeight -
        (topPadding +
            titleFontSize +
            spaceBetweenTextAndLogo +
            bottomSafeArea +
            bottomPadding +
            buttonHeightEstimate);

    final constrainedLogoSize = availableHeightForLogo.clamp(150.0, 300.0);

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: bottomSafeArea),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: topPadding),
            Padding(
              padding: EdgeInsets.only(left: horizontalPadding),
              child: Text(
                'PAWS',
                style: GoogleFonts.notoSerifDisplay(
                  fontSize: titleFontSize,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            SizedBox(height: spaceBetweenTextAndLogo),
            Center(
              child: FlutterLogo(
                size: constrainedLogoSize,
              ),
            ),
            SizedBox(height: screenHeight * 0.1),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.only(bottom: bottomSafeArea),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: bottomPadding,
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
      ),
    );
  }
}
