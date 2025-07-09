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
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isPortrait = mediaQuery.orientation == Orientation.portrait;

    // Adjust font size based on orientation
    final titleFontSize = isPortrait ? screenWidth * 0.08 : screenHeight * 0.08;

    final horizontalPadding = isPortrait ? screenWidth * 0.1 : screenWidth * 0.15;

    // Adjust spacings for orientation
    final topPadding = isPortrait ? screenHeight * 0.05 : screenHeight * 0.02;
    final spaceBetweenTextAndLogo = isPortrait ? screenHeight * 0.25 : screenHeight * 0.1;
    final bottomSafeArea = mediaQuery.padding.bottom + (isPortrait ? screenHeight * 0.1 : screenHeight * 0.05);
    final bottomPadding = isPortrait ? screenHeight * 0.02 : screenHeight * 0.01;
    final buttonHeightEstimate = isPortrait ? 50.0 : 40.0;

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
            SizedBox(height: isPortrait ? screenHeight * 0.1 : screenHeight * 0.05),
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
              SizedBox(height: isPortrait ? screenHeight * 0.01 : screenHeight * 0.005),
              const Text('Terms & Conditions apply'),
            ],
          ),
        ),
      ),
    );
  }
}
