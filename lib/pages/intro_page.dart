import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
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
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.05), // 5% of screen height
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.1), // 10% left padding
                  child: Text(
                    'Paws',
                    style: GoogleFonts.notoSerifDisplay(
                      fontSize: screenWidth * 0.08, // dynamic font size
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            CarouselSlider(
              items: [
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                      child: Lottie.asset(
                        'assets/lottie/ani1.json',
                        width: screenWidth * 0.9, // scale to screen
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                      child: Text(
                        '"For all your furry family members"',
                        style: GoogleFonts.notoSerifDisplay(
                          fontSize: screenWidth * 0.06, // scale font
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                ),
                Column(
                  children: [
                    SizedBox(height: screenHeight * 0.03),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                      child: Lottie.asset(
                        'assets/lottie/ani2.json',
                        width: screenWidth * 0.9,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                      child: Text(
                        '"Just like a paw, providing comfort and care for all pets"',
                        style: GoogleFonts.notoSerifDisplay(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                )
              ],
              options: CarouselOptions(
                autoPlay: true,
                enableInfiniteScroll: true,
                pageSnapping: true,
                viewportFraction: 1,
                height: screenHeight * 0.65, // dynamic height
                initialPage: 0,
                scrollDirection: Axis.horizontal,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            CTAButton(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AuthPage()),
              ),
              text: 'Get Started',
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: const Text('Terms & Conditions apply'),
            ),
          ],
        ),
      ),
    );
  }
}
