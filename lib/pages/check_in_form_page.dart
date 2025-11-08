import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:paws/model/animal_model.dart';
import 'package:paws/themes/themes.dart';
import 'package:paws/widgets/database_service.dart';

class CheckInFormPage extends StatefulWidget {
  final String clinicName;
  final String qrCode;

  const CheckInFormPage({
    super.key,
    required this.clinicName,
    required this.qrCode,
  });

  @override
  State<CheckInFormPage> createState() => _CheckInFormPageState();
}

class _CheckInFormPageState extends State<CheckInFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Form fields
  String? selectedPetId;
  String clientName = '';
  String? selectedPurpose;
  String? selectedVet;
  String? selectedDuration;
  DateTime? scheduledDateTime;
  String additionalNotes = '';
  String diagnosisNotes = '';
  
  // Data loading
  List<Animal> userPets = [];
  bool isLoading = true;
  
  final List<String> purposes = [
    'Routine Checkup',
    'Vaccination',
    'Emergency',
    'Surgery',
    'Grooming',
    'Dental Cleaning',
    'Follow up',
    'Consultation',
    'Other',
  ];
  
  final List<String> veterinarians = [
    'Jose Guillio',
    'Maria Santos',
  ];
  
  final List<String> durations = [
    '15m',
    '30m',
    '45m',
    '1hr',
    '1.5hrs',
    '2hrs',
    '3hrs',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      return;
    }

    try {
      // Load client name from profile
      final userDoc = await FirestoreService().read(
        collectionPath: 'users',
        docId: uid,
      );
      
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        clientName = data['owner'] ?? 'Unknown';
      }

      // Load user's pets
      final petsSnapshot = await FirebaseFirestore.instance
          .collection('users/$uid/pets')
          .get();

      userPets = petsSnapshot.docs.map((doc) {
        return Animal.fromMap(doc.id, doc.data());
      }).toList();

      if (mounted) {
        setState(() => isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          scheduledDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _submitCheckIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedPetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a pet')),
      );
      return;
    }

    if (selectedPurpose == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select check-in purpose')),
      );
      return;
    }

    if (selectedDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select estimated duration')),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      // Find the selected pet's details
      final selectedPet = userPets.firstWhere((pet) => pet.petID == selectedPetId);

      // Prepare check-in data
      final checkInData = {
        'userId': uid,
        'clientName': clientName,
        'petId': selectedPetId,
        'petName': selectedPet.name,
        'petType': selectedPet.type,
        'clinicName': widget.clinicName,
        'qrCode': widget.qrCode,
        'purpose': selectedPurpose,
        'diagnosis': selectedPurpose == 'Routine Checkup' ? diagnosisNotes : null,
        'assignedVet': selectedVet,
        'estimatedDuration': selectedDuration,
        'scheduledTime': scheduledDateTime?.toIso8601String(),
        'additionalNotes': additionalNotes.isNotEmpty ? additionalNotes : null,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('check_ins')
          .add(checkInData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-in submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Return to home or previous screen
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting check-in: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-In Form'),
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: secondaryColor))
          : userPets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.pets, size: 80, color: Colors.grey),
                      const SizedBox(height: 20),
                      const Text(
                        'No pets found',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Please add a pet in Pet Manager first',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => Navigator.pushReplacementNamed(context, '/pets'),
                        child: const Text('Go to Pet Manager'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Clinic info card
                        Card(
                          color: secondaryColor.withOpacity(0.1),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(Icons.local_hospital, color: secondaryColor),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Checking in at:',
                                        style: TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                      Text(
                                        widget.clinicName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 1. Pet Selection (Required)
                        _buildSectionTitle('Pet *'),
                        DropdownButtonFormField<String>(
                          value: selectedPetId,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Select your pet',
                          ),
                          items: userPets.map((pet) {
                            return DropdownMenuItem(
                              value: pet.petID,
                              child: Row(
                                children: [
                                  const Icon(Icons.pets, size: 20),
                                  const SizedBox(width: 8),
                                  Text('${pet.name} (${pet.type})'),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => selectedPetId = value);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a pet';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // 2. Client Name (Unchangeable)
                        _buildSectionTitle('Client Name'),
                        TextFormField(
                          initialValue: clientName,
                          enabled: false,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.black12,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 3. Check-in Purpose (Required)
                        _buildSectionTitle('Check-in Purpose *'),
                        ...purposes.map((purpose) {
                          return RadioListTile<String>(
                            title: Text(purpose),
                            value: purpose,
                            groupValue: selectedPurpose,
                            activeColor: secondaryColor,
                            onChanged: (value) {
                              setState(() {
                                selectedPurpose = value;
                                if (value != 'Routine Checkup') {
                                  diagnosisNotes = '';
                                }
                              });
                            },
                          );
                        }),
                        
                        // Conditional Diagnosis field for Routine Checkup
                        if (selectedPurpose == 'Routine Checkup') ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Diagnosis/Symptoms',
                              border: OutlineInputBorder(),
                              hintText: 'Describe symptoms or reason for checkup',
                            ),
                            onChanged: (value) => diagnosisNotes = value,
                          ),
                        ],
                        const SizedBox(height: 20),

                        // 4. Assigned Veterinarian (Optional)
                        _buildSectionTitle('Assigned Veterinarian (Optional)'),
                        DropdownButtonFormField<String>(
                          value: selectedVet,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Select veterinarian',
                          ),
                          items: veterinarians.map((vet) {
                            return DropdownMenuItem(
                              value: vet,
                              child: Text(vet),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => selectedVet = value);
                          },
                        ),
                        const SizedBox(height: 20),

                        // 5. Estimated Duration (Required)
                        _buildSectionTitle('Estimated Duration *'),
                        DropdownButtonFormField<String>(
                          value: selectedDuration,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Select duration',
                          ),
                          items: durations.map((duration) {
                            return DropdownMenuItem(
                              value: duration,
                              child: Text(duration),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => selectedDuration = value);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select estimated duration';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // 6. Scheduled Time (Optional)
                        _buildSectionTitle('Scheduled Time (Optional)'),
                        InkWell(
                          onTap: _selectDateTime,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              scheduledDateTime == null
                                  ? 'Select date and time'
                                  : DateFormat('MM/dd/yyyy hh:mm a').format(scheduledDateTime!),
                              style: TextStyle(
                                color: scheduledDateTime == null ? Colors.grey : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 7. Additional Notes (Optional)
                        _buildSectionTitle('Additional Notes (Optional)'),
                        TextFormField(
                          maxLines: 4,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Any additional information...',
                          ),
                          onChanged: (value) => additionalNotes = value,
                        ),
                        const SizedBox(height: 32),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: secondaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _submitCheckIn,
                            child: const Text(
                              'Submit Check-In',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
