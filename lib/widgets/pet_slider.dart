import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paws/model/animal_model.dart';
import 'package:paws/pages/pet_page.dart';
import 'package:paws/themes/themes.dart';
import 'package:paws/widgets/database_service.dart'; 
import 'package:paws/widgets/add_pet_dialog.dart';
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
        onTap: () => showAddPetDialog(context),
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
                        ? FileImage(File(animal.petImagePath)) as ImageProvider<Object>
                        : AssetImage(animal.petImagePath) as ImageProvider<Object>)
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

  
}
