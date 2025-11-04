import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      controller: petNameController,
                      decoration: const InputDecoration(labelText: 'Pet Name'),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty) ? 'Please enter pet name' : null,
                    ),
                  ),
                  const SizedBox(height: 12),
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
                if (formKey.currentState!.validate()) {
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


