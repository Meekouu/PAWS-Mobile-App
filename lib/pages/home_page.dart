import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paws/model/animal_model.dart';
import 'package:paws/pages/news/news_card_carousel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:paws/widgets/abstract_background_painter.dart';
import 'package:paws/widgets/pet_slider.dart';
import 'package:paws/widgets/bottom_navbar.dart';

Route createSlideRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}

class HomePage extends StatelessWidget {
  HomePage({super.key});

  void logOut(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await FirebaseAuth.instance.signOut();

    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  final List<Animal> animal = Animal.getAnimal();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _AppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PetSlider(animals: animal),
              const SizedBox(height: 10),
              _galleryPreview(),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'News',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              NewsCardCarousel(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
       bottomNavigationBar: BottomNavBar(
    currentIndex: 0,
    onTap: (index) {
      if (index == 0) return; // Already on Home
      if (index == 1) {
        Navigator.pushReplacementNamed(context, '/pets');
      } else if (index == 2) {
        Navigator.pushReplacementNamed(context, '/profile');
      }
    },
  ),
);
}


 Widget _galleryPreview() {
  final List<Map<String, String>> galleryItems = [
    {
      'image': 'assets/images/dog1.jpeg',
      'date': '20 Jun',
      'title': 'Visiting a Vet',
    },
    {
      'image': 'assets/images/cat1.jpeg',
      'date': '18 Jul',
      'title': 'Cat Vaccination',
    },
    {
      'image': 'assets/images/dog1.jpeg',
      'date': '10 Aug',
      'title': 'Puppy Check-up',
    },
  ];

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gallery Preview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 170,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: galleryItems.length,
            itemBuilder: (context, index) {
              final item = galleryItems[index];
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background abstract shapes
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CustomPaint(
                          painter: AbstractBackgroundPainter(),
                        ),
                      ),
                    ),

                    // Main content
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item['date']!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                          const Spacer(),
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.asset(
                                item['image']!,
                                height: 70,
                                width: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item['title']!,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}
  AppBar _AppBar(BuildContext context) {
    return AppBar(
      titleSpacing: 35,
      backgroundColor: Colors.blue[100],
      automaticallyImplyLeading: false,
      title: Text(
        'PAWS',
        style: GoogleFonts.notoSerifDisplay(
          fontSize: 35,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: IconButton(
            onPressed: () => logOut(context),
            icon: const Icon(
              Icons.logout_rounded,
              size: 30,
            ),
          ),
        )
      ],
    );
  }
}

