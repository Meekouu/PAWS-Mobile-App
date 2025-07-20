import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paws/model/animal_model.dart';
import 'package:paws/pages/weight_tracker_page.dart';
import 'package:paws/themes/themes.dart';
import 'package:paws/widgets/database_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final double coverHeight = 180;
  final double profileHeight = 100;

  String owner = '';
  String birthday = '';
  String country = '';

  File? profileImageFile;

  final uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> _pickImage() async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(source: ImageSource.gallery);

  if (picked != null) {
    setState(() {
      profileImageFile = File(picked.path);
    });
  }
}
  Future<void> loadUserData() async{
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null){
      final snapshot = await DatabaseService().read(path: 'users/$uid');
      if(snapshot != null && snapshot.exists){
        final data = snapshot.value as Map<dynamic, dynamic>;

        setState(() {
          owner = data['owner'] ?? 'No Name';
          birthday = data['ownerBirthday'] ?? 'No Birthday';
          country = data['ownerCountry'] ?? 'No Country';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(owner),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/images/Arrow - Left 2.svg',
            height: 20,
            width: 20,
          ),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
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
                child: GestureDetector(
                  onTap: _pickImage,
                  child: _buildProfileImage(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          _buildInfoCard(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCoverImage() => Container(
        height: coverHeight,
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(50),
          ),
        ),
      );

  Widget _buildProfileImage() {
    final String path = '';   //widget.animal.petImagePath ;
    ImageProvider? imageProvider;

    if (profileImageFile != null) {
      imageProvider = FileImage(profileImageFile!);
    } else if (path.isNotEmpty && path.startsWith('/')) {
      imageProvider = FileImage(File(path));
    } else if (path.isNotEmpty) {
      imageProvider = AssetImage(path);
    }

    return CircleAvatar(
      radius: profileHeight / 2,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: (profileHeight / 2) - 5,
        backgroundImage: imageProvider,
        child: imageProvider == null
            ? const Icon(Icons.pets, size: 40, color: Colors.black45)
            : null,
      ),
    );
  }

  Widget _buildInfoCard() {
    final ownerController = TextEditingController(text: owner);
    final birthdayController = TextEditingController(text: birthday);
    final countryController = TextEditingController(text: country);
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
                    "${owner}’s Information",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: const Text('Edit Owner Information'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: ownerController,
                                decoration: const InputDecoration(labelText: 'Breed'),
                              ),
                              TextField(
                                controller: birthdayController,
                                decoration: const InputDecoration(labelText: 'Sex'),
                              ),
                              TextField(
                                controller: countryController,
                                decoration: const InputDecoration(labelText: 'Date of Birth'),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // TODO: update backend
                                Navigator.of(context).pop();
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        );
                      },
                    ),
                    child: const Text(
                      "Edit",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.teal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow("Name", owner),
              const Divider(),
              _buildInfoRow("Birthday", birthday),
              const Divider(),
              _buildInfoRow("Country", country),
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
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String label, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap ?? () {
        debugPrint('$label clicked');
      },
    );
  }
}
