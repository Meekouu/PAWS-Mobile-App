import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class GalleryPage extends StatelessWidget {
  final List<String> galleryItems = [
    'assets/images/cat1.jpeg',
    'assets/images/dog1.jpeg',
    'assets/images/cat1.jpeg',
    'assets/images/dog1.jpeg',
    'assets/images/dog1.jpeg',
    'assets/images/cat1.jpeg',
    'assets/images/dog1.jpeg',
    'assets/images/cat1.jpeg',
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gallery"),
        backgroundColor: Colors.teal,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library_outlined),
            tooltip: "Gallery",
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemCount: galleryItems.length,
          itemBuilder: (context, index) {
            final imagePath = galleryItems[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Material(
                elevation: 2,
                shadowColor: Colors.black26,
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Tapped image ${index + 1}"),
                        backgroundColor: Colors.teal,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
