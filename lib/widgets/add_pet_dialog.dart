import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:paws/widgets/database_service.dart';
import 'package:paws/widgets/buttons_input_widgets.dart';

Future<void> showAddPetDialog(BuildContext context) async {
  final formKey = GlobalKey<FormState>();
  final petNameController = TextEditingController();
  final petBreedController = TextEditingController();
  final petBirthdayController = TextEditingController();
  String petType = 'Canine';
  String petSex = 'Male';
  File? petImageFile;
  bool isPickingImage = false;

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF998FC7),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.pets, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Add Pet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(40),
                    onTap: () async {
                      if (isPickingImage) return;
                      isPickingImage = true;
                      try {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(source: ImageSource.gallery);
                        if (picked != null) {
                          setState(() => petImageFile = File(picked.path));
                        }
                      } on PlatformException catch (e) {
                        if (e.code != 'already_active') rethrow;
                      } finally {
                        isPickingImage = false;
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: TextFormField(
                      controller: petNameController,
                      validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        hintText: 'Pet Name',
                        hintStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
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
                          borderSide: const BorderSide(color: Color(0xFF998FC7), width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: TextFormField(
                      controller: petBreedController,
                      validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        hintText: 'Breed',
                        hintStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
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
                          borderSide: const BorderSide(color: Color(0xFF998FC7), width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: TextFormField(
                      controller: petBirthdayController,
                      readOnly: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        hintText: 'Birthday (dd/mm/yyyy)',
                        hintStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
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
                          borderSide: const BorderSide(color: Color(0xFF998FC7), width: 2),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: DropdownButtonFormField<String>(
                      value: petSex,
                      items: ['Male', 'Female']
                          .map((sex) => DropdownMenuItem(value: sex, child: Text(sex)))
                          .toList(),
                      onChanged: (val) => setState(() => petSex = val ?? petSex),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
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
                          borderSide: const BorderSide(color: Color(0xFF998FC7), width: 2),
                        ),
                        hintText: 'Sex',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: DropdownButtonFormField<String>(
                      value: petType,
                      items: ['Canine', 'Feline', 'Other']
                          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (val) => setState(() => petType = val ?? petType),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
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
                          borderSide: const BorderSide(color: Color(0xFF998FC7), width: 2),
                        ),
                        hintText: 'Type',
                      ),
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
                if (formKey.currentState!.validate()) {
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid != null) {
                    final docId = const Uuid().v4();
                    String downloadUrl = '';
                    // Upload selected image to Firebase Storage if present
                    if (petImageFile != null) {
                      try {
                        final ref = FirebaseStorage.instance.ref()
                            .child('users')
                            .child(uid)
                            .child('pets')
                            .child(docId)
                            .child('profile.jpg');
                        await ref.putFile(petImageFile!);
                        downloadUrl = await ref.getDownloadURL();
                      } catch (e) {
                        // Fallback: continue without URL
                        debugPrint('Image upload failed: $e');
                      }
                    }

                    final petData = {
                      'petName': petNameController.text.trim(),
                      'petBreed': petBreedController.text.trim(),
                      'petBirthday': petBirthdayController.text.trim(),
                      'petType': petType,
                      'petSex': petSex,
                      // Keep legacy local path for backward compatibility
                      'petImagePath': petImageFile?.path ?? '',
                      // New: Firestore/Storage-backed image URL
                      'petImageUrl': downloadUrl,
                    };
                    await FirestoreService().create(
                      collectionPath: 'users/$uid/pets',
                      docId: docId,
                      data: petData,
                    );
                    if (context.mounted) Navigator.pop(context);
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


