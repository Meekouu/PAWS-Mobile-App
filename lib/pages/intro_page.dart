import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:paws/auth/auth.dart';
import 'package:paws/widgets/buttons_input_widgets.dart';
import 'package:paws/pages/login_page.dart';
import 'package:paws/themes/themes.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final isPortrait = mq.orientation == Orientation.portrait;

    final headerHeight = isPortrait ? size.height * 0.45 : size.height * 0.6;
    final sidePadding = isPortrait ? 24.0 : 40.0;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          Container(
            height: headerHeight + mq.padding.top,
            padding: EdgeInsets.only(top: mq.padding.top + 24, left: sidePadding, right: sidePadding),
            decoration: const BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PAWS',
                  style: GoogleFonts.notoSerifDisplay(
                    color: Colors.white,
                    fontSize: 42,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Care, track, and stay on top of your pet\'s health.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Center(
                  child: SizedBox(
                    height: isPortrait ? 160 : 140,
                    child: Lottie.asset('assets/lottie/paws_animation.json'),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(top: headerHeight - 40, left: sidePadding, right: sidePadding, bottom: mq.padding.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.vaccines, color: secondaryColor),
                            SizedBox(width: 8),
                            Expanded(child: Text('Vaccination reminders, all in one place.')),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: const [
                            Icon(Icons.pets, color: secondaryColor),
                            SizedBox(width: 8),
                            Expanded(child: Text('Manage multiple pets with profiles.')),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: const [
                            Icon(Icons.qr_code, color: secondaryColor),
                            SizedBox(width: 8),
                            Expanded(child: Text('Fast check-ins via QR scanning.')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  CTAButton(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AuthPage()),
                    ),
                    text: 'Get Started',
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    ),
                    child: const Text('I already have an account'),
                  ),
                  const SizedBox(height: 8),
                  const Text('Terms & Conditions apply'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
