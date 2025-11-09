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
  String? selectedDiagnosis;
  List<String> diagnosisOptions = [];
  bool loadingDiagnoses = true;
  
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
    _loadDiagnosisOptions();
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

    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;
    if (uid == null) return;

    try {
      // Find the selected pet's details
      final selectedPet = userPets.firstWhere((pet) => pet.petID == selectedPetId);

      // Lookup or create client in web 'clients' collection
      String? email = user?.email?.toLowerCase();
      // Split owner name into first/last (fallbacks)
      String firstName = clientName.trim();
      String lastName = '';
      if (firstName.contains(' ')) {
        final parts = firstName.split(RegExp(r"\s+")).where((s) => s.isNotEmpty).toList();
        firstName = parts.first;
        lastName = parts.sublist(1).join(' ');
      }

      String clientDocId;
      {
        QuerySnapshot<Map<String, dynamic>>? existing;
        if (email != null && email.isNotEmpty) {
          existing = await FirebaseFirestore.instance
              .collection('clients')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();
        }
        if (existing != null && existing.docs.isNotEmpty) {
          clientDocId = existing.docs.first.id;
        } else {
          final clientDoc = await FirebaseFirestore.instance.collection('clients').add({
            'firstName': firstName,
            'lastName': lastName,
            'email': email ?? null,
            'phone': '',
            'address': {
              'street': '',
              'city': '',
              'state': '',
              'zipCode': '',
              'country': ''
            },
            'dateOfBirth': null,
            'notes': '',
            'isActive': true,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'createdBy': uid,
            'updatedBy': uid,
            'animalCount': 0,
          });
          clientDocId = clientDoc.id;
        }
      }

      // Ensure selected animal exists in web 'animals' for that client
      String animalDocId;
      {
        final existing = await FirebaseFirestore.instance
            .collection('animals')
            .where('clientId', isEqualTo: clientDocId)
            .where('name', isEqualTo: selectedPet.name)
            .limit(1)
            .get();
        if (existing.docs.isNotEmpty) {
          animalDocId = existing.docs.first.id;
        } else {
          DateTime? parsedDob;
          try {
            // Try common formats: dd/MM/yyyy or ISO
            if (selectedPet.birthday != null && selectedPet.birthday.toString().isNotEmpty) {
              try {
                parsedDob = DateFormat('dd/MM/yyyy').parse(selectedPet.birthday);
              } catch (_) {
                parsedDob = DateTime.tryParse(selectedPet.birthday);
              }
            }
          } catch (_) {}

          final animalDoc = await FirebaseFirestore.instance.collection('animals').add({
            'clientId': clientDocId,
            'name': selectedPet.name,
            'species': (selectedPet.type ?? '').toString().toLowerCase(),
            'breed': (selectedPet.breed ?? '').toString(),
            'color': '',
            'sex': (selectedPet.sex ?? '').toString().isNotEmpty ? selectedPet.sex : 'unknown',
            'dateOfBirth': parsedDob != null ? Timestamp.fromDate(parsedDob) : null,
            'weight': null,
            'microchipId': null,
            'isSpayedNeutered': false,
            'medicalHistory': [],
            'vaccinations': [],
            'allergies': [],
            'medications': [],
            'notes': '',
            'isActive': true,
            'isDeceased': false,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'createdBy': uid,
            'updatedBy': uid,
            'clientName': '$firstName ${lastName}'.trim(),
          });
          animalDocId = animalDoc.id;
          // Increment animalCount on client
          await FirebaseFirestore.instance.collection('clients').doc(clientDocId).update({
            'animalCount': FieldValue.increment(1),
            'updatedAt': FieldValue.serverTimestamp(),
            'updatedBy': uid,
          });
        }
      }

      // Map UI purpose labels to web enum keys
      String mapPurpose(String? p) {
        switch (p) {
          case 'Routine Checkup':
            return 'routine_checkup';
          case 'Vaccination':
            return 'vaccination';
          case 'Emergency':
            return 'emergency';
          case 'Surgery':
            return 'surgery';
          case 'Grooming':
            return 'grooming';
          case 'Dental Cleaning':
            return 'dental_cleaning';
          case 'Follow up':
            return 'follow_up';
          case 'Consultation':
            return 'consultation';
          default:
            return 'other';
        }
      }

      // Convert duration label to minutes number
      int? mapDurationToMinutes(String? d) {
        if (d == null) return null;
        if (d.endsWith('m')) {
          return int.tryParse(d.replaceAll('m', ''));
        }
        if (d.endsWith('hr') || d.endsWith('hrs')) {
          final n = d.replaceAll('hr', '').replaceAll('hrs', '');
          final val = double.tryParse(n);
          if (val != null) return (val * 60).round();
        }
        return null;
      }

      final now = DateTime.now();
      final checkInTime = DateFormat('HH:mm').format(now);

      // Prepare check-in data aligned with web schema
      final checkInData = <String, dynamic>{
        // Web-expected fields
        'animalId': animalDocId,
        'animalName': selectedPet.name,
        'clientId': clientDocId,
        'clientName': '$firstName ${lastName}'.trim(),
        'checkInDate': FieldValue.serverTimestamp(),
        'checkInTime': checkInTime,
        'purpose': mapPurpose(selectedPurpose),
        'status': 'checked_in',
        'notes': additionalNotes.isNotEmpty ? additionalNotes : null,
        'diagnosis': selectedPurpose == 'Routine Checkup' && diagnosisNotes.isNotEmpty ? diagnosisNotes : null,
        'veterinarian': selectedVet,
        'estimatedDuration': mapDurationToMinutes(selectedDuration),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'createdBy': uid,

        // Extra mobile-specific context (safe to keep)
        'petType': selectedPet.type,
        'clinicName': widget.clinicName,
        'qrCode': widget.qrCode,
        'scheduledTime': scheduledDateTime?.toIso8601String(),
      }..removeWhere((k, v) => v == null);

      // Save to Firestore
      await FirebaseFirestore.instance.collection('check_ins').add(checkInData);

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
                          _buildSectionTitle('Diagnosis/Symptoms *'),
                          loadingDiagnoses
                              ? const Center(child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(color: secondaryColor),
                                ))
                              : DropdownButtonFormField<String>(
                                  value: selectedDiagnosis,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Select diagnosis/symptoms',
                                  ),
                                  items: diagnosisOptions.map((d) => DropdownMenuItem(
                                        value: d,
                                        child: Text(d),
                                      )).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedDiagnosis = value;
                                      diagnosisNotes = value ?? '';
                                    });
                                  },
                                  validator: (value) {
                                    if (selectedPurpose == 'Routine Checkup' && (value == null || value.isEmpty)) {
                                      return 'Please select a diagnosis';
                                    }
                                    return null;
                                  },
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
