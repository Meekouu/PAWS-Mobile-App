import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/animal_model.dart';
import '../widgets/vaccine_reminder_card.dart';
import '../widgets/database_service.dart';
import '../themes/themes.dart';
import '../pages/all_vaccines_page.dart';

class VaccineReminderSection extends StatefulWidget {
  const VaccineReminderSection({super.key});

  @override
  State<VaccineReminderSection> createState() => _VaccineReminderSectionState();
}

class _VaccineReminderSectionState extends State<VaccineReminderSection> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.vaccines, color: Colors.blue, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Vaccine Reminders',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AllVaccinesPage(animals: animals),
                        ),
                      );
                    },
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Carousel for vaccine cards
            SizedBox(
              height: 240,
              child: PageView.builder(
                controller: _pageController,
                itemCount: animals.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: KeyedSubtree(
                      key: ValueKey(animals[index].petID),
                      child: VaccineReminderCard(
                        key: PageStorageKey(animals[index].petID),
                        petName: animals[index].name,
                        petId: animals[index].petID,
                      ),
                    ),
                  );
                },
              ),
            ),
            // Page indicators (only show if more than 1 pet)
            if (animals.length > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  animals.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    width: _currentPage == index ? 18 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? tertiaryColor : Colors.grey[400],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
