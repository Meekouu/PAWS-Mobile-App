import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:paws/model/animal_model.dart';
import 'package:paws/pages/weight_tracker_page.dart';
import 'package:paws/themes/themes.dart';
import 'package:paws/widgets/database_service.dart';

class PetPage extends StatefulWidget {
  final String petId;

  const PetPage({Key? key, required this.petId}) : super(key: key);

  @override
  State<PetPage> createState() => _PetPageState();
}

class _PetPageState extends State<PetPage> {
  
  Animal? animal;
  final TextEditingController breedController = TextEditingController();
  final TextEditingController sexController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final double coverHeight = 180;
  final double profileHeight = 100;

  File? petImageFile;

  @override
  void initState() {
    super.initState();
    _fetchAnimal();
  }
  @override
  void dispose() {
  breedController.dispose();
  sexController.dispose();
  dobController.dispose();
  super.dispose();
}

  Future<void> _fetchAnimal() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final snapshot = await FirebaseDatabase.instance
          .ref('pet/$uid/${widget.petId}')
          .get();

      if (snapshot.exists) {
        final data = snapshot.value as Map;
        final loadedAnimal = Animal.fromMap(widget.petId, data);
        setState(() {
          animal = Animal.fromMap(widget.petId, data);
          breedController.text = loadedAnimal.breed;
          sexController.text = loadedAnimal.sex;
          dobController.text = loadedAnimal.birthday;
        });
      }
    }
  }

  Future<void> _pickImage() async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(source: ImageSource.gallery);
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final petId = widget.petId;

  if (picked != null) {
    setState(() {
      petImageFile = File(picked.path);
    });
    if (uid != null && petId.isNotEmpty) {
      await DatabaseService().update(
        path: 'pet/$uid/$petId',
        data: {'petImagePath' : picked.path}
      );
    }
  }

}

 Future<void> _deletePetFromDatabase() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final petId = animal?.petID;

  if (uid != null && petId != null && petId.isNotEmpty) {
    await DatabaseService().delete(path: 'pet/$uid/$petId');
    if (mounted) Navigator.of(context).pop();
  }
}


  @override
  Widget build(BuildContext context) {
    final pet = animal;
    if (pet == null) {
      return Scaffold(
        body: Center(
          child: Lottie.asset(
            'assets/lottie/loading.json',
            width: 120,
            height: 120,
            repeat: true,
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.grey[100],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(pet.name),
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
    icon: const Icon(Icons.delete),
    onPressed: () async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Delete Pet Profile'),
          content: const Text('Are you sure you want to delete this pet profile?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              child: const Text('Delete'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await _deletePetFromDatabase();
      }
    },
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
                child: GestureDetector(
                  onTap: _pickImage,
                  child: _buildProfileImage(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          _buildInfoCard(pet),
          const SizedBox(height: 20),
          _buildListTile(Icons.folder_shared, "Medical Records"),
          _buildListTile(Icons.memory, "Chipping"),
          _buildListTile(Icons.local_pharmacy, "Prescriptions"),
          _buildListTile(Icons.verified_user, "Insurance"),
          _buildListTile(
            Icons.monitor_weight,
            "Weight Tracker",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => WeightTrackerPage()),
              );
            },
          ),
          const SizedBox(height: 30),
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
    final String path = animal?.petImagePath ?? '';

    ImageProvider? imageProvider;

    if (petImageFile != null) {
      imageProvider = FileImage(petImageFile!);
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

  Widget _buildInfoCard(Animal animal) {
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
                  GestureDetector(
                    onTap: () => showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: const Text('Edit Pet Information'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: breedController,
                                decoration: const InputDecoration(labelText: 'Breed'),
                              ),
                              TextField(
                                controller: sexController,
                                decoration: const InputDecoration(labelText: 'Sex'),
                              ),
                              TextField(
                                controller: dobController,
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
                              onPressed: () async {
                                final uid = FirebaseAuth.instance.currentUser?.uid;
                                final petId = animal.petID;

                                if (uid != null && petId.isNotEmpty){
                                  final updatedData={
                                    'petBreed': breedController.text,
                                    'petSex': sexController.text,
                                    'petBirthday': dobController.text,
                                  };

                                  await DatabaseService().update(
                                    path: 'pet/$uid/$petId',
                                    data: updatedData,
                                  );

                                  setState(() {
                                    animal.breed = breedController.text;
                                    animal.sex = sexController.text;
                                    animal.birthday = dobController.text;
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
                        color: Colors.teal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow("Breed", animal.breed),
              const Divider(),
              _buildInfoRow("Sex", animal.sex),
              const Divider(),
              _buildInfoRow("Date of Birth", animal.birthday),
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
