import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paws/model/animal_model.dart';
import 'package:paws/pages/pet_page.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paws/widgets/database_service.dart';

class PetSlider extends StatelessWidget {
  const PetSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return FutureBuilder(
      future: Future.wait([
        DatabaseService().read(path: 'users/$uid'),
        DatabaseService().read(path: 'pet/$uid')
        ]),

      builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }

      if (!snapshot.hasData ||
        snapshot.data == null ||
        snapshot.data!.length < 2) {
        return const Center(child: Text('No user data found.'));
      }

      final userSnapshot = snapshot.data![0];
      final petSnapshot = snapshot.data![1];

      final userMap = userSnapshot?.value as Map<dynamic, dynamic>? ?? {};
      final String name = userMap['owner'] ?? 'Unknown';

      final petMap = petSnapshot?.value as Map<dynamic, dynamic>? ?? {};

      List<Animal> animals = petMap.entries.map((entry) {
        final petData = entry.value as Map<dynamic, dynamic>;
        return Animal.fromMap(petData);
      }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              'Hi $name!,',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: animals.length + 1,
              itemBuilder: (context, index) {
                if (index == animals.length) {
                  return _buildAddPetButton(context);
                } else {
                  return _buildPetItem(context, animals[index]);
                }
              },
            ),
          ),
        ],
      ),
      );
      }
    );
  }

  Widget _buildAddPetButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GestureDetector(
        onTap: () {
          _showAddPetDialog(context);
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
  }

  Widget _buildPetItem(BuildContext context, Animal animal) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PetPage(animal: animal),
            ),
          );
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
                backgroundImage: animal.petImagePath != null && animal.petImagePath.isNotEmpty
                    ? (animal.petImagePath.startsWith('/') // crude check for file path
                        ? FileImage(File(animal.petImagePath))
                        : AssetImage(animal.petImagePath) as ImageProvider)
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 80,
              child: Text(
                animal.name,
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

  void _showAddPetDialog(BuildContext context) {
    final petNameController = TextEditingController();
    final petBreedController = TextEditingController();
    final petBirthdayController = TextEditingController();
    String petType = 'Canine';
    String petSex = 'Male';
    File? petImageFile;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Add Pet'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(40),
                      onTap: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(source: ImageSource.gallery);
                        if (picked != null) {
                          setState(() {
                            petImageFile = File(picked.path);
                          });
                        }
                      },
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: petImageFile != null ? FileImage(petImageFile!) : null,
                        child: petImageFile == null
                            ? const Icon(Icons.add, size: 40, color: Colors.black54)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: petNameController,
                    decoration: const InputDecoration(labelText: 'Pet Name'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: petBreedController,
                    decoration: const InputDecoration(labelText: 'Breed'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: petBirthdayController,
                    decoration: const InputDecoration(labelText: 'Birthday (dd/mm/yyyy)'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: petSex,
                    items: ['Male', 'Female']
                        .map((sex) => DropdownMenuItem(value: sex, child: Text(sex)))
                        .toList(),
                    onChanged: (val) => petSex = val ?? petSex,
                    decoration: const InputDecoration(labelText: 'Sex'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: petType,
                    items: ['Canine', 'Feline', 'Other']
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (val) => petType = val ?? petType,
                    decoration: const InputDecoration(labelText: 'Type'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid != null) {
                    final petData = {
                      'petName': petNameController.text.trim(),
                      'petBreed': petBreedController.text.trim(),
                      'petBirthday': petBirthdayController.text.trim(),
                      'petType': petType,
                      'petSex': petSex,
                      'petImagePath': petImageFile?.path ?? '',
                    };
                    await DatabaseService().create(
                      path: 'pet/$uid/${DateTime.now().millisecondsSinceEpoch}',
                      data: petData,
                    );
                  }
                  Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          ),
        );
      },
    );
  }
}
