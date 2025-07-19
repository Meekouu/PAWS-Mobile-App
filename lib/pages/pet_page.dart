import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:paws/model/animal_model.dart';

class PetPage extends StatelessWidget {
  final Animal animal;

  const PetPage({Key? key, required this.animal}) : super(key: key);

  final double coverHeight = 180;
  final double profileHeight = 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(animal.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/images/Arrow - Left 2.svg',
            height: 20,
            width: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {}, // Placeholder
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              _buildCoverImage(),
              Positioned(
                top: coverHeight - profileHeight / 2,
                child: _buildProfileImage(),
              ),
            ],
          ),
          const SizedBox(height: 60),
          _buildInfoCard(context),
          const SizedBox(height: 20),
          _buildListTile(Icons.folder_shared, "Medical Records"),
          _buildListTile(Icons.memory, "Chipping"),
          _buildListTile(Icons.local_pharmacy, "Prescriptions"),
          _buildListTile(Icons.verified_user, "Insurance"),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildCoverImage() => Container(
        height: coverHeight,
        decoration: BoxDecoration(
          color: const Color(0xFFA8D5BA),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(50),
          ),
        ),
      );

  Widget _buildProfileImage() => CircleAvatar(
        radius: profileHeight / 2,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: (profileHeight / 2) - 5,
          backgroundImage: AssetImage(animal.imagePicture),
        ),
      );

  Widget _buildInfoCard(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${animal.name}’s Information",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const Text(
                  "Edit",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.teal,
                    fontWeight: FontWeight.w600,
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow("Breed", animal.breed),
            const Divider(),
            _buildInfoRow("Sex", animal.sex), // Static for now
            const Divider(),
            _buildInfoRow("Date of Birth", animal.birthday), // Placeholder
          ],
        ),
      ),
    ),
  );
}

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Placeholder for backend navigation
        debugPrint('$label clicked');
      },
    );
  }
}
