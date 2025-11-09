import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/vaccine_model.dart';
import 'package:uuid/uuid.dart';

class VaccineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ===== User-space Vaccine Storage (preferred) =====
  CollectionReference<Map<String, dynamic>> _userPetsRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('pets');

  CollectionReference<Map<String, dynamic>> _petVaccinationsRef(String uid, String petId) =>
      _userPetsRef(uid).doc(petId).collection('vaccinations');

  Future<bool> addVaccinationForUserPetId({
    required String petId,
    required String petName,
    required String vaccineName,
    required DateTime dateGiven,
    required DateTime nextDueDate,
    String? veterinarian,
    String? batchNumber,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    try {
      final docId = const Uuid().v4();
      await _petVaccinationsRef(user.uid, petId).doc(docId).set({
        'id': docId,
        'name': vaccineName,
        'date': Timestamp.fromDate(dateGiven),
        'nextDueDate': Timestamp.fromDate(nextDueDate),
        'veterinarian': veterinarian ?? 'Mobile App',
        'batchNumber': batchNumber,
        'isUpToDate': nextDueDate.isAfter(DateTime.now()),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'petId': petId,
        'petName': petName,
      });
      return true;
    } catch (e) {
      print('Error addVaccinationForUserPetId: $e');
      return false;
    }
  }

  Future<bool> updateVaccinationForUserPetId({
    required String petId,
    required String vaccineId,
    required String vaccineName,
    required DateTime dateGiven,
    required DateTime nextDueDate,
    String? veterinarian,
    String? batchNumber,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return false;
    try {
      await _petVaccinationsRef(user.uid, petId).doc(vaccineId).update({
        'name': vaccineName,
        'date': Timestamp.fromDate(dateGiven),
        'nextDueDate': Timestamp.fromDate(nextDueDate),
        'veterinarian': veterinarian ?? 'Mobile App',
        'batchNumber': batchNumber,
        'isUpToDate': nextDueDate.isAfter(DateTime.now()),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updateVaccinationForUserPetId: $e');
      return false;
    }
  }

  Future<List<Vaccination>> getUserVaccinationsForPetId(String petId) async {
    final user = _auth.currentUser;
    if (user == null) return [];
    try {
      final qs = await _petVaccinationsRef(user.uid, petId).orderBy('nextDueDate').get();
      return qs.docs.map((d) => Vaccination.fromMap(d.data())).toList();
    } catch (e) {
      print('Error getUserVaccinationsForPetId: $e');
      return [];
    }
  }

  Future<Map<String, List<Vaccination>>> getAllUserPetVaccinations() async {
    final user = _auth.currentUser;
    if (user == null) return {};
    try {
      final pets = await _userPetsRef(user.uid).get();
      final Map<String, List<Vaccination>> result = {};
      for (final p in pets.docs) {
        final data = p.data();
        // Use the correct field used in user pets docs
        final name = (data['petName'] ?? data['name'] ?? 'Unknown').toString();
        final petId = p.id;
        final list = await getUserVaccinationsForPetId(petId);
        if (list.isNotEmpty) {
          result[name] = list;
        }
      }
      return result;
    } catch (e) {
      print('Error getAllUserPetVaccinations (user-space): $e');
      return {};
    }
  }

  // ===== Legacy web-dashboard helpers (kept for read-only fallback) =====
  // Get all vaccinations for a specific animal from the web 'animals' collection
  Future<List<Vaccination>> getVaccinationsForAnimal(String animalId) async {
    try {
      final animalDoc = await _firestore.collection('animals').doc(animalId).get();
      if (!animalDoc.exists) return [];
      final data = animalDoc.data();
      if (data == null || !data.containsKey('vaccinations')) return [];
      final vaccinationsData = data['vaccinations'] as List<dynamic>?;
      if (vaccinationsData == null || vaccinationsData.isEmpty) return [];
      return vaccinationsData.map((v) => Vaccination.fromMap(v as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching vaccinations for animal (web): $e');
      return [];
    }
  }

  // ===== Summaries =====
  Future<Map<String, dynamic>> getVaccineSummaryForPetId(String petId, String petName) async {
    try {
      final list = await getUserVaccinationsForPetId(petId);
      if (list.isEmpty) {
        return {'total': 0, 'upToDate': 0, 'dueSoon': 0, 'overdue': 0, 'nextDue': null};
      }
      int upToDate = 0, dueSoon = 0, overdue = 0;
      Vaccination? nextDueVaccine;
      for (final v in list) {
        switch (v.status) {
          case 'overdue':
            overdue++; break;
          case 'due':
          case 'due_soon':
            dueSoon++; break;
          case 'up_to_date':
            upToDate++; break;
          default:
            break;
        }
        if (nextDueVaccine == null || v.nextDueDate.isBefore(nextDueVaccine.nextDueDate)) {
          if (v.daysUntilDue >= 0) nextDueVaccine = v;
        }
      }
      return {
        'total': list.length,
        'upToDate': upToDate,
        'dueSoon': dueSoon,
        'overdue': overdue,
        'nextDue': nextDueVaccine,
      };
    } catch (e) {
      print('Error getVaccineSummaryForPetId: $e');
      return {'total': 0, 'upToDate': 0, 'dueSoon': 0, 'overdue': 0, 'nextDue': null};
    }
  }

  // Get upcoming/overdue reminders still rely on any reminder docs if present (optional)

  // Get vaccine reminders for the current user's pets
  Future<List<VaccineReminder>> getVaccineRemindersForUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      // Get user's email to find their client record
      final email = user.email?.toLowerCase();
      if (email == null || email.isEmpty) return [];

      // Find client by email
      final clientQuery = await _firestore
          .collection('clients')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (clientQuery.docs.isEmpty) return [];

      final clientId = clientQuery.docs.first.id;

      // Get vaccine reminders for this client
      final remindersQuery = await _firestore
          .collection('vaccine_reminders')
          .where('clientId', isEqualTo: clientId)
          .orderBy('currentDueDate', descending: false)
          .get();

      return remindersQuery.docs
          .map((doc) => VaccineReminder.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching vaccine reminders: $e');
      return [];
    }
  }

  // Get upcoming vaccine reminders (due within 14 days or overdue)
  Future<List<VaccineReminder>> getUpcomingReminders() async {
    try {
      final allReminders = await getVaccineRemindersForUser();
      
      // Filter for reminders that are due within 14 days or overdue
      return allReminders.where((reminder) {
        return reminder.daysUntilExpiry <= 14;
      }).toList();
    } catch (e) {
      print('Error fetching upcoming reminders: $e');
      return [];
    }
  }

  // Get overdue vaccine reminders
  Future<List<VaccineReminder>> getOverdueReminders() async {
    try {
      final allReminders = await getVaccineRemindersForUser();
      
      return allReminders.where((reminder) {
        return reminder.reminderType == 'overdue';
      }).toList();
    } catch (e) {
      print('Error fetching overdue reminders: $e');
      return [];
    }
  }

  // Get summary of vaccine status for a specific pet
  Future<Map<String, dynamic>> getVaccineSummaryForPet(String petName) async {
    try {
      final allVaccinations = await getAllUserPetVaccinations();
      final petVaccinations = allVaccinations[petName] ?? [];

      if (petVaccinations.isEmpty) {
        return {
          'total': 0,
          'upToDate': 0,
          'dueSoon': 0,
          'overdue': 0,
          'nextDue': null,
        };
      }

      int upToDate = 0;
      int dueSoon = 0;
      int overdue = 0;
      Vaccination? nextDueVaccine;

      for (var vaccine in petVaccinations) {
        final status = vaccine.status;
        
        if (status == 'overdue') {
          overdue++;
        } else if (status == 'due' || status == 'due_soon') {
          dueSoon++;
        } else if (status == 'up_to_date') {
          upToDate++;
        }

        // Track the next due vaccine
        if (nextDueVaccine == null || vaccine.nextDueDate.isBefore(nextDueVaccine.nextDueDate)) {
          if (vaccine.daysUntilDue >= 0) {
            nextDueVaccine = vaccine;
          }
        }
      }

      return {
        'total': petVaccinations.length,
        'upToDate': upToDate,
        'dueSoon': dueSoon,
        'overdue': overdue,
        'nextDue': nextDueVaccine,
      };
    } catch (e) {
      print('Error getting vaccine summary for pet: $e');
      return {
        'total': 0,
        'upToDate': 0,
        'dueSoon': 0,
        'overdue': 0,
        'nextDue': null,
      };
    }
  }
}
