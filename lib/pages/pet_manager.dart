import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paws/model/animal_model.dart';
import 'package:paws/pages/pet_page.dart';
import 'package:paws/pages/home_page.dart';
import 'package:paws/themes/themes.dart';
import 'package:paws/widgets/database_service.dart'; // use Firestore instead of RealtimeDB
import 'package:flutter_svg/flutter_svg.dart';
import 'package:paws/widgets/add_pet_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PetManager extends StatefulWidget {
  const PetManager({super.key});

  @override
  State<PetManager> createState() => _PetManagerState();
}

class _PetManagerState extends State<PetManager> {
  late String? uid;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> _deletePet(String petId) async {
    if (uid != null) {
      await FirestoreService().delete(
        collectionPath: 'users/$uid/pets',
        docId: petId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (uid == null) return const Center(child: Text('No user found'));

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
          (route) => false,
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Pets'),
          centerTitle: true,
          backgroundColor: secondaryColor,
          foregroundColor: Colors.white,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/images/Arrow - Left 2.svg',
            height: 20,
            width: 20,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => HomePage()),
              (route) => false,
            );
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().streamCollection('users/$uid/pets'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No pets added yet."));
          }

          final pets = snapshot.data!.docs.map((doc) {
            return Animal.fromMap(doc.id, doc.data() as Map<String, dynamic>);
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];
              return _buildPetCard(pet);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddPetDialog(context),
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  Widget _buildPetCard(Animal pet) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: pet.petImagePath.isNotEmpty
              ? (pet.petImagePath.startsWith('/')
                  ? FileImage(File(pet.petImagePath))
                  : AssetImage(pet.petImagePath)) as ImageProvider
              : null,
          child: pet.petImagePath.isEmpty
              ? const Icon(Icons.pets, size: 30, color: Colors.grey)
              : null,
        ),
        title: Text(pet.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${pet.breed} • ${pet.sex}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Delete Pet'),
                content: const Text('Are you sure you want to delete this pet?'),
                actions: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  ElevatedButton(
                    child: const Text('Delete'),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              await _deletePet(pet.petID);
            }
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PetPage(petId: pet.petID)),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/profile');
            break;
        }
      },
      selectedItemColor: primaryColor,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.pets), label: "Pets"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}
