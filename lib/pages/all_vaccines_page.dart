import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/animal_model.dart';
import '../model/vaccine_model.dart';
import '../services/vaccine_service.dart';
import '../themes/themes.dart';
import 'vaccine_details_page.dart';
import '../widgets/vaccine_reminder_card.dart';

class AllVaccinesPage extends StatelessWidget {
  final List<Animal> animals;
  const AllVaccinesPage({super.key, required this.animals});

  @override
  Widget build(BuildContext context) {
    final sortedAnimals = [...animals]..sort((a, b) => a.petID.compareTo(b.petID));

    return DefaultTabController(
      length: sortedAnimals.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vaccine Records'),
          backgroundColor: secondaryColor,
          foregroundColor: Colors.white,
          bottom: TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            indicatorColor: Colors.white,
            tabs: [
              for (final animal in sortedAnimals)
                Tab(text: animal.name),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            for (final animal in sortedAnimals)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: VaccineReminderCard(
                  petName: animal.name,
                  petId: animal.petID,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
