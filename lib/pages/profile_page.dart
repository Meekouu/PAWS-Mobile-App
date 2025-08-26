import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paws/themes/themes.dart';
import 'package:paws/widgets/database_service.dart';
import 'package:paws/widgets/bottomnav_bar.dart'; 


class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

final List<String> allCountries = ['United States', 'Canada', 'UK', 'Philippines'];
String? selectedCountry;

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController ownerController;
  late TextEditingController birthdayController;

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
    ownerController = TextEditingController();
    birthdayController = TextEditingController();
    loadUserData();
  }
  @override
  void dispose() {
  ownerController.dispose();
  birthdayController.dispose();
  super.dispose();
}

Future<void> _pickImage() async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(source: ImageSource.gallery);

  if (picked != null) {
    setState(() {
      profileImageFile = File(picked.path);
    });

    if (uid != null) {
      await FirestoreService().update(
        collectionPath: 'users',
        docId: uid!,
        data: {'ownerImagePath': picked.path}, // keeping local path until you add Storage
      );
    }
  }
}

Future<void> loadUserData() async {
  if (uid != null) {
    final snapshot = await FirestoreService().read(
      collectionPath: 'users',
      docId: uid!,
    );

    if (snapshot != null && snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;

      setState(() {
        owner = data['owner'] ?? 'No Name';
        birthday = data['ownerBirthday'] ?? 'No Birthday';
        country = data['ownerCountry'] ?? 'Country';
        selectedCountry = country;
        profileImageFile = (data['ownerImagePath'] != null &&
                data['ownerImagePath'].toString().startsWith('/'))
            ? File(data['ownerImagePath'])
            : null;

        ownerController.text = owner;
        birthdayController.text = birthday;
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
    behavior: HitTestBehavior.translucent,
    onTap: _pickImage,
    child: Container(
      width: profileHeight + 30, 
      height: profileHeight + 30,
      alignment: Alignment.center,
      child: _buildProfileImage(),
    ),
  ),
),

          ],
        ),
        const SizedBox(height: 60),
        _buildInfoCard(),
        const SizedBox(height: 20),
      ],
    ),
    bottomNavigationBar: bottomnavbar(
    currentIndex: 2, // Profile is index 2
    onTap: (index) {
      if (index == 0) {
        Navigator.pushReplacementNamed(context, '/home');
      } else if (index == 1) {
        Navigator.pushReplacementNamed(context, '/pets');
      } else if (index == 2) {
        // Already on Profile
      }
    },
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
  ImageProvider? imageProvider;

  if (profileImageFile != null) {
    imageProvider = FileImage(profileImageFile!);
  }

  return Stack(
    children: [
      CircleAvatar(
        radius: profileHeight / 2,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: (profileHeight / 2) - 5,
          backgroundImage: imageProvider,
          child: imageProvider == null
              ? const Icon(Icons.person, size: 40, color: Colors.black45)
              : null,
        ),
      ),
      // Positioned camera icon at bottom-right
      Positioned(
  bottom: 0,
  right: 0,
  child: GestureDetector(
    onTap: _pickImage,
    child: Container(
      decoration: BoxDecoration(
        color: secondaryColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      padding: const EdgeInsets.all(4),
      child: const Icon(
        Icons.camera_alt,
        size: 20,
        color: Colors.white,
      ),
    ),
  ),
),

    ],
  );
}



  Widget _buildInfoCard() {
    final ownerController = TextEditingController(text: owner);
    final birthdayController = TextEditingController(text: birthday);
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
                                decoration: const InputDecoration(labelText: 'Name'),
                              ),
                              TextField(
                                controller: birthdayController,
                                decoration: const InputDecoration(labelText: 'Date of Birth'),
                                readOnly: true,  // Make it read-only so user taps only to pick date
                                onTap: () async {
                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.tryParse(birthdayController.text) ?? DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                  );

                                  if (pickedDate != null) {
                                    final formatted = "${pickedDate.day.toString().padLeft(2, '0')}/"
                                                      "${pickedDate.month.toString().padLeft(2, '0')}/"
                                                      "${pickedDate.year}";
                                    setState(() {
                                      birthdayController.text = formatted;
                                    });
                                  }
                                },
                              ),

                              DropdownButtonFormField<String>(
                                value: selectedCountry == 'Country' ? null : selectedCountry,
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => selectedCountry = val);
                                  }
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Country',
                                  border: UnderlineInputBorder(), // default Material underline
                                ),
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    enabled: false,
                                    child: Text(
                                      'Country',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  ...allCountries.map((country) => DropdownMenuItem(
                                    value: country,
                                    child: Text(country),
                                  )),
                                ],
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                              final trimmedName = ownerController.text.trim();
                              final trimmedBirthday = birthdayController.text.trim();
                              final selected = selectedCountry?.trim();

                              if (trimmedName.isEmpty || trimmedBirthday.isEmpty || selected == null || selected.isEmpty || selected == 'Country') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('All fields must be filled out.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              if (uid != null) {
                              final updatedData = {
                                'owner': trimmedName,
                                'ownerBirthday': trimmedBirthday,
                                'ownerCountry': selected,
                              };

                              await FirestoreService().update(
                                collectionPath: 'users',
                                docId: uid!,
                                data: updatedData,
                              );

                              setState(() {
                                owner = trimmedName;
                                birthday = trimmedBirthday;
                                country = selected;
                              });
                            }


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
                        color: secondaryColor,
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
}
