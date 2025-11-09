import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/animal_model.dart';
import '../widgets/database_service.dart';
import '../themes/themes.dart';
import '../pages/all_vaccines_page.dart';
import '../services/vaccine_service.dart';
import '../model/vaccine_model.dart';

class VaccineReminderSection extends StatefulWidget {
  const VaccineReminderSection({super.key});

  @override
  State<VaccineReminderSection> createState() => _VaccineReminderSectionState();
}

class _VaccineReminderSectionState extends State<VaccineReminderSection> {

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService().streamCollection('users/$uid/pets'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const SizedBox.shrink();
        }

        List<Animal> animals = docs.map((doc) {
          return Animal.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();
        // Ensure stable ordering to avoid widget churn between rebuilds
        animals.sort((a, b) => (a.petID).compareTo(b.petID));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compact summary tile
            FutureBuilder<Map<String, List<Vaccination>>>(
              future: VaccineService().getAllUserPetVaccinations(),
              builder: (context, vaccSnapshot) {
                if (vaccSnapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final data = vaccSnapshot.data ?? {};

                int total = 0;
                int overdue = 0;
                int dueSoon = 0; // includes 'due'
                int upToDate = 0; // includes 'upcoming'
                Vaccination? nextDue;

                for (final entry in data.entries) {
                  for (final v in entry.value) {
                    total++;
                    final s = v.status;
                    if (s == 'overdue') {
                      overdue++;
                    } else if (s == 'due' || s == 'due_soon') {
                      dueSoon++;
                    } else if (s == 'up_to_date' || s == 'upcoming') {
                      upToDate++;
                    }
                    if (v.daysUntilDue >= 0) {
                      if (nextDue == null || v.nextDueDate.isBefore(nextDue!.nextDueDate)) {
                        nextDue = v;
                      }
                    }
                  }
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.vaccines, color: Colors.blue, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Your Pets\' Vaccines',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Summary counts
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStat('Total', total, Colors.grey[700]!),
                            _buildStat('Overdue', overdue, Colors.red),
                            _buildStat('Due Soon', dueSoon, Colors.orange),
                            _buildStat('Up to Date', upToDate, Colors.green),
                          ],
                        ),

                        if (nextDue != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.event, color: Colors.blue[700], size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Next: ${nextDue!.name} • Due ${_formatDate(nextDue!.nextDueDate)}',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: nextDue!.daysUntilDue < 7 ? Colors.orange : Colors.blue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${nextDue!.daysUntilDue}d',
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AllVaccinesPage(animals: animals),
                                ),
                              );
                            },
                            icon: const Icon(Icons.list_alt, size: 18),
                            label: const Text('See All'),
                            style: TextButton.styleFrom(
                              foregroundColor: secondaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

Widget _buildStat(String label, int value, Color color) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        '$value',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.black54),
      ),
    ],
  );
}

String _formatDate(DateTime date) {
  return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
}
