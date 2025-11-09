import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/animal_model.dart';
import '../model/vaccine_model.dart';
import '../services/vaccine_service.dart';
import '../themes/themes.dart';
import 'add_vaccination_page.dart';

class AllVaccinesPage extends StatefulWidget {
  final List<Animal> animals;
  const AllVaccinesPage({super.key, required this.animals});

  @override
  State<AllVaccinesPage> createState() => _AllVaccinesPageState();
}

class _AllVaccinesPageState extends State<AllVaccinesPage> {
  late final List<Animal> _animals;
  int _current = 0;
  final VaccineService _service = VaccineService();
  Map<String, Map<String, dynamic>> _summaries = {}; // petId -> summary
  bool _loadingSummaries = true;
  int _refreshTick = 0; // forces rebuild when incremented
  Map<String, List<Vaccination>> _vaccinationsByPet = {}; // petId -> list
  bool _loadingList = true;
  String _filterStatus = 'all'; // 'all', 'overdue', 'due_soon', 'up_to_date'

  @override
  void initState() {
    super.initState();
    _animals = [...widget.animals]..sort((a, b) => a.petID.compareTo(b.petID));
    _loadSummaries();
    _loadVaccinationsForCurrent();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadSummaries() async {
    setState(() => _loadingSummaries = true);
    final Map<String, Map<String, dynamic>> map = {};
    for (final a in _animals) {
      final s = await _service.getVaccineSummaryForPetId(a.petID, a.name);
      map[a.petID] = s;
    }
    if (!mounted) return;
    setState(() {
      _summaries = map;
      _loadingSummaries = false;
    });
  }

  Future<void> _loadVaccinationsForCurrent() async {
    if (_animals.isEmpty) return;
    setState(() => _loadingList = true);
    final petId = _animals[_current].petID;
    final list = await _service.getUserVaccinationsForPetId(petId);
    if (!mounted) return;
    setState(() {
      _vaccinationsByPet[petId] = list;
      _loadingList = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaccine Records'),
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        actions: const [],
      ),
      body: Column(
        children: [
          // Story-like avatar slider with status border
          Center(
            child: SizedBox(
              height: 140,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: _animals.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                final a = _animals[index];
                final summary = _summaries[a.petID];
                final borderColor = _statusBorderColor(summary);
                final isSelected = index == _current;
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        setState(() => _current = index);
                        await _loadVaccinationsForCurrent();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? borderColor : borderColor.withOpacity(0.6),
                            width: isSelected ? 3 : 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white,
                          backgroundImage: a.petImageUrl.isNotEmpty
                              ? NetworkImage(a.petImageUrl)
                              : (
                                  a.petImagePath.isNotEmpty
                                      ? (a.petImagePath.startsWith('/')
                                          ? Image.file(File(a.petImagePath)).image
                                          : AssetImage(a.petImagePath) as ImageProvider)
                                      : null
                                ),
                          child: (a.petImageUrl.isEmpty && a.petImagePath.isEmpty)
                              ? const Icon(Icons.pets, color: secondaryColor)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 88,
                      child: Text(
                        a.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            ),
          ),

          // Filter chips row (affects list below)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: Colors.grey[50],
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('All', 'all', Icons.list),
                  const SizedBox(width: 8),
                  _filterChip('Overdue', 'overdue', Icons.warning_amber_rounded),
                  const SizedBox(width: 8),
                  _filterChip('Due Soon', 'due_soon', Icons.schedule),
                  const SizedBox(width: 8),
                  _filterChip('Up to Date', 'up_to_date', Icons.check_circle),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Vaccine list for selected pet
          Expanded(
            child: _loadingList
                ? const Center(child: CircularProgressIndicator())
                : _buildVaccinesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: secondaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final pet = _animals[_current];
          final added = await showDialog<bool>(
            context: context,
            builder: (_) => AddVaccinationDialog(
              petName: pet.name,
              petId: pet.petID,
            ),
          );
          if (added == true) {
            setState(() => _refreshTick++);
            // refresh this pet's summary
            final s = await _service.getVaccineSummaryForPetId(pet.petID, pet.name);
            if (!mounted) return;
            setState(() {
              _summaries[pet.petID] = s;
            });
            await _loadVaccinationsForCurrent();
          }
        },
      ),
    );
  }

  Color _statusBorderColor(Map<String, dynamic>? s) {
    if (s == null) return Colors.transparent;
    final overdue = (s['overdue'] ?? 0) as int;
    final dueSoon = (s['dueSoon'] ?? 0) as int;
    final total = (s['total'] ?? 0) as int;
    if (overdue > 0) return Colors.red;
    if (dueSoon > 0) return Colors.orange;
    if (total > 0) return Colors.green;
    return Colors.grey.shade300;
  }

  Widget _filterChip(String label, String value, IconData icon) {
    final isSelected = _filterStatus == value;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.black87),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) {
        setState(() => _filterStatus = value);
      },
      selectedColor: secondaryColor,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
      backgroundColor: Colors.grey[200],
      checkmarkColor: Colors.white,
      showCheckmark: false,
    );
  }

  List<Vaccination> get _currentFilteredVaccines {
    if (_animals.isEmpty) return [];
    final petId = _animals[_current].petID;
    final list = _vaccinationsByPet[petId] ?? [];
    if (_filterStatus == 'all') return list;
    return list.where((v) {
      final s = v.status;
      switch (_filterStatus) {
        case 'overdue':
          return s == 'overdue';
        case 'due_soon':
          return s == 'due' || s == 'due_soon';
        case 'up_to_date':
          return s == 'up_to_date' || s == 'upcoming';
        default:
          return true;
      }
    }).toList();
  }

  Widget _buildVaccinesList() {
    final list = _currentFilteredVaccines;
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.vaccines_outlined, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 12),
              Text(
                _filterStatus == 'all' ? 'No Vaccines Found' : 'No Vaccines Match Filter',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                _filterStatus == 'all' ? 'Add a vaccine using the + button' : 'Try a different filter',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _loadSummaries();
        await _loadVaccinationsForCurrent();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: list.length,
        itemBuilder: (context, index) => _buildVaccineCard(list[index]),
      ),
    );
  }

  Widget _buildVaccineCard(Vaccination vaccine) {
    final status = vaccine.status;
    final statusColor = _statusColor(status);
    final statusLabel = _statusLabel(status);
    final statusIcon = _statusIcon(status);
    final daysUntilDue = vaccine.daysUntilDue;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    vaccine.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(statusLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _detailRow(Icons.event, 'Last Given', DateFormat('MMM dd, yyyy').format(vaccine.date), Colors.blue),
            const SizedBox(height: 8),
            _detailRow(Icons.event_available, 'Next Due', DateFormat('MMM dd, yyyy').format(vaccine.nextDueDate), statusColor),
            const SizedBox(height: 8),
            _detailRow(
              Icons.timer,
              'Days Until Due',
              daysUntilDue < 0 ? '${daysUntilDue.abs()} days overdue' : daysUntilDue == 0 ? 'Due today' : '$daysUntilDue days',
              statusColor,
            ),
            if (vaccine.batchNumber != null && vaccine.batchNumber!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _detailRow(Icons.qr_code, 'Batch Number', vaccine.batchNumber!, Colors.grey),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'overdue':
        return Colors.red;
      case 'due':
      case 'due_soon':
        return Colors.orange;
      case 'upcoming':
        return Colors.blue;
      case 'up_to_date':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'overdue':
        return 'Overdue';
      case 'due':
        return 'Due Today';
      case 'due_soon':
        return 'Due Soon';
      case 'upcoming':
        return 'Upcoming';
      case 'up_to_date':
        return 'Up to Date';
      default:
        return 'Unknown';
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'overdue':
        return Icons.warning_amber_rounded;
      case 'due':
      case 'due_soon':
        return Icons.schedule;
      case 'upcoming':
        return Icons.event;
      case 'up_to_date':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }
}
