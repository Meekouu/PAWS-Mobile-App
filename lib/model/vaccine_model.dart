import 'package:cloud_firestore/cloud_firestore.dart';

class Vaccination {
  String id;
  String name;
  DateTime date;
  DateTime nextDueDate;
  String veterinarian;
  String? batchNumber;
  bool isUpToDate;

  Vaccination({
    required this.id,
    required this.name,
    required this.date,
    required this.nextDueDate,
    required this.veterinarian,
    this.batchNumber,
    required this.isUpToDate,
  });

  factory Vaccination.fromMap(Map<String, dynamic> map) {
    return Vaccination(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Unknown Vaccine',
      date: _parseDate(map['date']),
      nextDueDate: _parseDate(map['nextDueDate']),
      veterinarian: map['veterinarian'] ?? 'Unknown',
      batchNumber: map['batchNumber'],
      isUpToDate: map['isUpToDate'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': Timestamp.fromDate(date),
      'nextDueDate': Timestamp.fromDate(nextDueDate),
      'veterinarian': veterinarian,
      'batchNumber': batchNumber,
      'isUpToDate': isUpToDate,
    };
  }

  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is Timestamp) return date.toDate();
    if (date is DateTime) return date;
    if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
    return DateTime.now();
  }

  int get daysUntilDue {
    final now = DateTime.now();
    final difference = nextDueDate.difference(now);
    return difference.inDays;
  }

  String get status {
    final days = daysUntilDue;
    if (days < 0) return 'overdue';
    if (days == 0) return 'due';
    if (days <= 7) return 'due_soon';
    if (days <= 14) return 'upcoming';
    return 'up_to_date';
  }

  String get priority {
    final days = daysUntilDue;
    if (days < 0) return 'urgent';
    if (days <= 1) return 'high';
    if (days <= 7) return 'high';
    if (days <= 14) return 'medium';
    return 'low';
  }
}

class VaccineReminder {
  String id;
  String animalId;
  String animalName;
  String clientId;
  String clientName;
  String vaccinationId;
  String vaccinationName;
  DateTime currentDueDate;
  DateTime nextDueDate;
  int daysUntilExpiry;
  String reminderType; // 'upcoming', 'due', 'overdue'
  String priority; // 'low', 'medium', 'high', 'urgent'
  bool isNotified;
  DateTime? notificationSentAt;
  DateTime createdAt;
  DateTime updatedAt;

  VaccineReminder({
    required this.id,
    required this.animalId,
    required this.animalName,
    required this.clientId,
    required this.clientName,
    required this.vaccinationId,
    required this.vaccinationName,
    required this.currentDueDate,
    required this.nextDueDate,
    required this.daysUntilExpiry,
    required this.reminderType,
    required this.priority,
    required this.isNotified,
    this.notificationSentAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VaccineReminder.fromMap(String id, Map<String, dynamic> map) {
    return VaccineReminder(
      id: id,
      animalId: map['animalId'] ?? '',
      animalName: map['animalName'] ?? 'Unknown',
      clientId: map['clientId'] ?? '',
      clientName: map['clientName'] ?? 'Unknown',
      vaccinationId: map['vaccinationId'] ?? '',
      vaccinationName: map['vaccinationName'] ?? 'Unknown Vaccine',
      currentDueDate: Vaccination._parseDate(map['currentDueDate']),
      nextDueDate: Vaccination._parseDate(map['nextDueDate']),
      daysUntilExpiry: map['daysUntilExpiry'] ?? 0,
      reminderType: map['reminderType'] ?? 'upcoming',
      priority: map['priority'] ?? 'low',
      isNotified: map['isNotified'] ?? false,
      notificationSentAt: map['notificationSentAt'] != null 
          ? Vaccination._parseDate(map['notificationSentAt']) 
          : null,
      createdAt: Vaccination._parseDate(map['createdAt']),
      updatedAt: Vaccination._parseDate(map['updatedAt']),
    );
  }
}
