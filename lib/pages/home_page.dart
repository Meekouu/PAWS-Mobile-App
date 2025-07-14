import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paws/pages/news.dart';
import 'package:paws/pages/gallery.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  await prefs.clear(); 

  await FirebaseAuth.instance.signOut();
  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
}

  final List<IconData> petIcons = [
    Icons.pets,
    Icons.pets,
    Icons.pets,
  ];

  final List<String> petNames = [
    'Pet Name',
    'Pet Name',
    'Pet Name',
  ];

  final List<_PlaceholderItem> placeholders = [
    _PlaceholderItem(
      label: 'News Outlet',
      color: Colors.blue.shade200,
      icon: Icons.newspaper,
      onTapRoute: NewsFeedPage(),
    ),
    _PlaceholderItem(
      label: 'Gallery',
      color: Colors.purple.shade200,
      icon: Icons.photo_album,
      onTapRoute: GalleryPage(),
    ),
    _PlaceholderItem(
      label: 'Vaccination Status',
      color: Colors.green.shade200,
      icon: Icons.medical_services,
    ),
    _PlaceholderItem(
      label: 'More',
      color: Colors.orange.shade200,
      icon: Icons.more_horiz,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
              child: SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  itemCount: 4, 
                  itemBuilder: (context, index) {
                    if (index == 3) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: GestureDetector(
                          onTap: () {
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey.shade600, width: 3),
                                ),
                                child: CircleAvatar(
                                  radius: 48,
                                  backgroundColor: Colors.grey.shade300,
                                  child: const Icon(
                                    Icons.add,
                                    size: 50,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const SizedBox(
                                width: 80,
                                child: Text(
                                  'Add Pet',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: GestureDetector(
                          onTap: () {
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.brown.shade700,
                                    width: 3,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 48,
                                  backgroundColor: Colors.grey.shade200,
                                  child: Icon(
                                    petIcons[index],
                                    size: 60,
                                    color: Colors.brown.shade700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 80,
                                child: Text(
                                  petNames[index],
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: 600,
                child: MasonryGridView.count(
                  physics: const BouncingScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  itemCount: placeholders.length,
                  itemBuilder: (context, index) {
                    final item = placeholders[index];

                    final double height = 250 + (index % 3) * 40;

                    return GestureDetector(
                      onTap: () {
                        if (item.onTapRoute != null) {
                          Navigator.push(
                            context,
                            createSlideRoute(item.onTapRoute!),
                          );
                        } else if (item.onTap != null) {
                          item.onTap!();
                        }
                      },
                      child: Container(
                        height: height,
                        decoration: BoxDecoration(
                          color: item.color,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(item.icon, size: 48, color: Colors.white),
                            const SizedBox(height: 12),
                            Text(
                              item.label,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderItem {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? onTapRoute;

  _PlaceholderItem({
    required this.label,
    required this.color,
    required this.icon,
    this.onTap,
    this.onTapRoute,
  });
}
