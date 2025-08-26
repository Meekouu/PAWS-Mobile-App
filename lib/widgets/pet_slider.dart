import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paws/model/animal_model.dart';
import 'package:paws/pages/pet_page.dart';
import 'package:paws/themes/themes.dart';
import 'package:paws/widgets/database_service.dart'; 
import 'package:uuid/uuid.dart';
import 'package:paws/widgets/buttons_input_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PetSlider extends StatelessWidget {
  const PetSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    // 🔹 Get user doc first
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
  future: FirestoreService().read(
    collectionPath: 'users',
    docId: uid,
  ),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final userMap = userSnapshot.data?.data() as Map<String, dynamic>? ?? {};
        final String name = userMap['owner'] ?? 'User';

        // 🔹 Then stream pets under this user
        return StreamBuilder<QuerySnapshot>(
          stream: FirestoreService().streamCollection(
            'users/$uid/pets',
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final docs = snapshot.data?.docs ?? [];
            List<Animal> animals = docs.map((doc) {
              return Animal.fromMap(doc.id, doc.data() as Map<String, dynamic>);
            }).toList();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.black,
                        ),
                        children: [
                          const TextSpan(text: 'Hi '),
                          TextSpan(
                            text: '$name!',
                            style: const TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
          },
        );
      },
    );
  }

  Widget _buildAddPetButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GestureDetector(
        onTap: () => _showAddPetDialog(context),
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
                backgroundColor: Colors.grey.shade300,
                child: const Icon(Icons.add, size: 50, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 8),
            const SizedBox(
              width: 80,
              child: Text(
                'Add Pet',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
            MaterialPageRoute(builder: (context) => PetPage(petId: animal.petID)),
          );
        },
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: secondaryColor, width: 4),
              ),
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                backgroundImage: animal.petImagePath.isNotEmpty
                    ? (animal.petImagePath.startsWith('/')
                        ? FileImage(File(animal.petImagePath))
                        : AssetImage(animal.petImagePath) as ImageProvider)
                    : null,
                child: animal.petImagePath.isEmpty
                    ? const Icon(Icons.pets, size: 40, color: Colors.grey)
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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPetDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
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
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Add Pet'),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(40),
                      onTap: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(source: ImageSource.gallery);
                        if (picked != null) {
                          setState(() => petImageFile = File(picked.path));
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
                    const SizedBox(height: 12),

                    // Name
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        controller: petNameController,
                        decoration: const InputDecoration(labelText: 'Pet Name'),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty) ? 'Please enter pet name' : null,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Breed
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        controller: petBreedController,
                        decoration: const InputDecoration(labelText: 'Breed'),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty) ? 'Please enter breed' : null,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Birthday
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        controller: petBirthdayController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Birthday (dd/mm/yyyy)',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            final formatted =
                                "${pickedDate.day.toString().padLeft(2, '0')}/"
                                "${pickedDate.month.toString().padLeft(2, '0')}/"
                                "${pickedDate.year}";
                            petBirthdayController.text = formatted;
                          }
                        },
                        validator: (value) =>
                            (value == null || value.trim().isEmpty) ? 'Please pick a birthday' : null,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Sex Dropdown
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: DropdownButtonFormField<String>(
                        value: petSex,
                        items: ['Male', 'Female']
                            .map((sex) => DropdownMenuItem(value: sex, child: Text(sex)))
                            .toList(),
                        onChanged: (val) => setState(() => petSex = val ?? petSex),
                        decoration: const InputDecoration(labelText: 'Sex'),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Type Dropdown
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: DropdownButtonFormField<String>(
                        value: petType,
                        items: ['Canine', 'Feline', 'Other']
                            .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                            .toList(),
                        onChanged: (val) => setState(() => petType = val ?? petType),
                        decoration: const InputDecoration(labelText: 'Type'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            actionsPadding: const EdgeInsets.symmetric(vertical: 10),
            actions: [
              CTAButton(
                text: 'Add',
                onTap: () async {
                  if (_formKey.currentState!.validate()) {
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
                      await FirestoreService().create(
                        collectionPath: 'users/$uid/pets',
                        docId: const Uuid().v4(),
                        data: petData,
                      );
                      Navigator.pop(context);
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
