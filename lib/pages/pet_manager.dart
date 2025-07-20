import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:paws/model/animal_model.dart';
import 'package:paws/pages/pet_page.dart';
import 'package:paws/themes/themes.dart';
import 'package:paws/widgets/database_service.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      await DatabaseService().delete(path: 'pet/$uid/$petId');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (uid == null) return const Center(child: Text('No user found'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Pets'),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/images/Arrow - Left 2.svg',
            height: 20,
            width: 20,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: DatabaseService().stream('pet/$uid'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final petMap = snapshot.data?.snapshot.value as Map<dynamic, dynamic>? ?? {};

          if (petMap.isEmpty) {
            return const Center(child: Text("No pets added yet."));
          }

          final pets = petMap.entries.map((entry) {
            final petId = entry.key.toString();
            final petData = entry.value as Map;
            return Animal.fromMap(petId, petData);
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
      bottomNavigationBar: _buildBottomNavigationBar(context),
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
