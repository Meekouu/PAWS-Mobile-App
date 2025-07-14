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
    final size = mediaQuery.size;
    final isPortrait = mediaQuery.orientation == Orientation.portrait;

    final horizontalPadding = isPortrait ? size.width * 0.1 : size.width * 0.15;
    final topPadding = isPortrait ? size.height * 0.05 : size.height * 0.02;
    final spaceBetweenTextAndLogo = isPortrait ? size.height * 0.15 : size.height * 0.1;
    final bottomPadding = isPortrait ? size.height * 0.02 : size.height * 0.01;
    final bottomSafeArea = mediaQuery.padding.bottom + (isPortrait ? size.height * 0.1 : size.height * 0.05);
    final buttonHeight = isPortrait ? 50.0 : 40.0;

    final titleFontSize = isPortrait ? size.width * 0.08 : size.height * 0.08;

    final aspectRatio = size.width / size.height;
    final baseSize = isPortrait ? size.height : size.width;
    final scaleFactor = (1 / aspectRatio).clamp(0.7, 1.3);
    final logoSize = (baseSize * 0.3 * scaleFactor).clamp(150.0, 300.0);

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
              child: Image.asset(
                'assets/images/paw-placeholder.png',
                width: logoSize,
                height: logoSize,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: isPortrait ? size.height * 0.1 : size.height * 0.05),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.only(bottom: bottomSafeArea),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: bottomPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CTAButton(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AuthPage()),
                ),
                text: 'Get Started',
              ),
              SizedBox(height: isPortrait ? size.height * 0.01 : size.height * 0.005),
              const Text('Terms & Conditions apply'),
            ],
          ),
        ),
      ),
    );
  }
}