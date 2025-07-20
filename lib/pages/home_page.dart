import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paws/model/animal_model.dart';
import 'package:paws/pages/news/news_card_carousel.dart';
import 'package:paws/themes/themes.dart';
import 'package:paws/widgets/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:paws/widgets/abstract_background_painter.dart';
import 'package:paws/widgets/pet_slider.dart';
import 'package:paws/widgets/bottomnav_bar.dart';

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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userName;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  String? userProfileImage;

Future<void> _loadUserInfo() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final snapshot = await DatabaseService().read(path: 'users/${user.uid}');
    if (snapshot != null) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      final imagePath = data['ownerImagePath'];
      String? validPath;

      // Check if local file path exists
      if (imagePath != null && imagePath.toString().startsWith('/')) {
        final file = File(imagePath);
        if (await file.exists()) {
          validPath = imagePath;
        }
      }

      setState(() {
        userName = data['owner'] ?? 'No Name';
        userEmail = data['email'] ?? user.email ?? 'No Email';
        userProfileImage = validPath; // Null if file is missing
      });
    } else {
      setState(() {
        userName = 'User';
        userEmail = user.email ?? '';
        userProfileImage = null;
      });
    }
  }
}



  void logOut(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await FirebaseAuth.instance.signOut();

    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  Widget _buildProfileImage(String imagePath) {
  if (imagePath.startsWith('http')) {
    // For future use if Firebase Storage added
    return ClipOval(
      child: Image.network(
        imagePath,
        fit: BoxFit.cover,
        width: 55,
        height: 55,
        errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 30, color: secondaryColor),
      ),
    );
  } else {
    final file = File(imagePath);
    if (file.existsSync()) {
      return ClipOval(
        child: Image.file(
          file,
          fit: BoxFit.cover,
          width: 55,
          height: 55,
          errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 30, color: secondaryColor),
        ),
      );
    } else {
      return const Icon(Icons.person, size: 30, color: secondaryColor);
    }
  }
}



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
              PetSlider(),
                const Divider(
                thickness: 1,
                color: Colors.grey,
                indent: 20,
                endIndent: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
              ),
              NewsCardCarousel(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
       bottomNavigationBar: bottomnavbar(
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
  drawer: Drawer(
  child: ListView(
    padding: EdgeInsets.zero,
    children: [
      // Header with profile picture
      DrawerHeader(
        decoration: const BoxDecoration(color: secondaryColor),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: userProfileImage != null
                  ? _buildProfileImage(userProfileImage!)
                  : Icon(Icons.person, size: 30, color: secondaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName ?? 'Loading...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    userEmail ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // New Drawer items
      ListTile(
        leading: const Icon(Icons.info_outline),
        title: const Text('About Us'),
        onTap: () {
          Navigator.pop(context);
          showAboutDialog(
            context: context,
            applicationName: 'PAWS',
            applicationVersion: '1.0.0',
            applicationIcon: Icon(Icons.pets, color: secondaryColor),
            children: [
              const Text('PAWS is your companion in managing pet care and vet appointments.'),
            ],
          );
        },
      ),
      ListTile(
        leading: const Icon(Icons.support_agent),
        title: const Text('Contact Support'),
        onTap: () {
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Contact Support'),
              content: const Text('Email us at: support@pawsclinic.com'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
      ),
      ListTile(
        leading: const Icon(Icons.feedback_outlined),
        title: const Text('Feedback'),
        onTap: () {
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Send Feedback'),
              content: const Text('We’d love to hear your thoughts!\nSend feedback to feedback@pawsclinic.com'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
      ),

      const Divider(),

      // Log Out option
      ListTile(
        leading: const Icon(Icons.logout),
        title: const Text('Log Out'),
        onTap: () async {
          final shouldLogout = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Log Out'),
              content: const Text('Are you sure you want to log out?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Log Out'),
                ),
              ],
            ),
          );
          if (shouldLogout == true) {
            logOut(context);
          }
        },
      ),
    ],
  ),
),

);
}
//remove gallery for now
/*
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
} */
  AppBar _AppBar(BuildContext context) {
    return AppBar(
      titleSpacing: 35,
      backgroundColor: secondaryColor,
      automaticallyImplyLeading: false,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, size: 30),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Text(
        'PAWS',
        style: GoogleFonts.notoSerifDisplay(
          fontSize: 35,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
            ),
          ),
    );
  }
}


