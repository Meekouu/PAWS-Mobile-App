import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:paws/model/animal_model.dart';
import 'package:paws/pages/vaccine_details_page.dart';
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
  bool _isPickingImage = false;
  

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
      final snapshot = await FirestoreService().read(
        collectionPath: 'users/$uid/pets',
        docId: widget.petId,
      );

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
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
  if (_isPickingImage) return;
  _isPickingImage = true;
  try {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final petId = widget.petId;

    if (picked != null) {
      if (!mounted) return;
      setState(() {
        petImageFile = File(picked.path);
      });
      if (uid != null && petId.isNotEmpty) {
        String downloadUrl = '';
        try {
          final ref = FirebaseStorage.instance.ref()
              .child('users')
              .child(uid)
              .child('pets')
              .child(petId)
              .child('profile.jpg');
          await ref.putFile(File(picked.path));
          downloadUrl = await ref.getDownloadURL();
        } catch (e) {
          debugPrint('Pet image upload failed: $e');
        }

        await FirestoreService().update(
          collectionPath: 'users/$uid/pets',
          docId: petId,
          data: {
            'petImagePath': picked.path, // legacy fallback
            'petImageUrl': downloadUrl,
          },
        );
      }
    }
  } on PlatformException catch (e) {
    if (e.code != 'already_active') rethrow;
  } finally {
    _isPickingImage = false;
  }
}

Future<void> _deletePetFromDatabase() async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final petId = animal?.petID;

  if (uid != null && petId != null && petId.isNotEmpty) {
    await FirestoreService().delete(
      collectionPath: 'users/$uid/pets',
      docId: petId,
    );
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
        backgroundColor: secondaryColor,
        elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
        foregroundColor: Colors.white.withValues(alpha: 0.8),
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/images/Arrow - Left 2.svg',
            height: 20,
            width: 20,
            colorFilter: ColorFilter.mode(
              Colors.white.withValues(alpha: 0.8),
              BlendMode.srcIn,
            ),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: const [
                Icon(Icons.warning_amber_rounded, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Delete Pet Profile',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          content: const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('Are you sure you want to delete this pet profile?'),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: secondaryColor, foregroundColor: Colors.white),
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
          SizedBox(
            height: coverHeight + MediaQuery.of(context).padding.top + (profileHeight / 2),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                _buildCoverImage(),
                Positioned(
  top: coverHeight + MediaQuery.of(context).padding.top - profileHeight / 2,
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
          ),
          const SizedBox(height: 100),
          _buildInfoCard(pet),
          const SizedBox(height: 20),
          _buildListTile(
            Icons.vaccines,
            "Vaccine Information",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VaccineDetailsPage(
                    petName: pet.name,
                    petId: pet.petID,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildCoverImage() => Container(
        height: coverHeight + MediaQuery.of(context).padding.top,
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(50),
          ),
        ),
      );

  Widget _buildProfileImage() {
  final String url = animal?.petImageUrl ?? '';
  final String path = animal?.petImagePath ?? '';

  ImageProvider? imageProvider;

  if (petImageFile != null) {
    imageProvider = FileImage(petImageFile!);
  } else if (url.isNotEmpty) {
    imageProvider = NetworkImage(url);
  } else if (path.isNotEmpty && path.startsWith('/')) {
    imageProvider = FileImage(File(path));
  } else if (path.isNotEmpty) {
    imageProvider = AssetImage(path);
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
              ? const Icon(Icons.pets, size: 40, color: Colors.black45)
              : null,
        ),
      ),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          titlePadding: EdgeInsets.zero,
                          title: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                              color: secondaryColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.edit, color: Colors.white),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Edit Pet Information',
                                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          content: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  controller: breedController,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                                    hintText: 'Breed',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(40),
                                      borderSide: const BorderSide(color: Colors.black),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(40),
                                      borderSide: const BorderSide(color: Colors.black),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(40),
                                      borderSide: const BorderSide(color: secondaryColor, width: 2),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: sexController,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                                    hintText: 'Sex',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(40),
                                      borderSide: const BorderSide(color: Colors.black),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(40),
                                      borderSide: const BorderSide(color: Colors.black),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(40),
                                      borderSide: const BorderSide(color: secondaryColor, width: 2),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: dobController,
                                  readOnly: true,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                                    hintText: 'Date of Birth',
                                    suffixIcon: const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(40),
                                      borderSide: const BorderSide(color: Colors.black),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(40),
                                      borderSide: const BorderSide(color: Colors.black),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(40),
                                      borderSide: const BorderSide(color: secondaryColor, width: 2),
                                    ),
                                  ),
                                  onTap: () async {
                                    final pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime.now(),
                                    );

                                    if (pickedDate != null) {
                                      final formatted = "${pickedDate.day.toString().padLeft(2, '0')}/"
                                                        "${pickedDate.month.toString().padLeft(2, '0')}/"
                                                        "${pickedDate.year}";
                                      setState(() => dobController.text = formatted);
                                    }
                                  },
                                ),

                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: secondaryColor, foregroundColor: Colors.white),
                              onPressed: () async {
                              final breed = breedController.text.trim();
                              final sex = sexController.text.trim();
                              final dob = dobController.text.trim();

                              if (breed.isEmpty || sex.isEmpty || dob.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('All fields must be filled out.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              final uid = FirebaseAuth.instance.currentUser?.uid;
                              final petId = animal.petID;

                              if (uid != null && petId.isNotEmpty) {
                                final updatedData = {
                                  'petBreed': breed,
                                  'petSex': sex,
                                  'petBirthday': dob,
                                };

                                await FirestoreService().update(
                                collectionPath: 'users/$uid/pets', // ✅ subcollection inside user doc
                                docId: petId, // ✅ which pet to update
                                data: updatedData,
                              );

                                setState(() {
                                  animal.breed = breed;
                                  animal.sex = sex;
                                  animal.birthday = dob;
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
      leading: Icon(icon, color: secondaryColor),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap ?? () {
        debugPrint('$label clicked');
      },
    );
  }
}
