import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/animal_model.dart';
import '../model/vaccine_model.dart';
import '../services/vaccine_service.dart';
import '../themes/themes.dart';
import 'vaccine_details_page.dart';

class AllVaccinesPage extends StatefulWidget {
  final List<Animal> animals;
  const AllVaccinesPage({super.key, required this.animals});

  @override
  State<AllVaccinesPage> createState() => _AllVaccinesPageState();
}

class _AllVaccinesPageState extends State<AllVaccinesPage> {
  final VaccineService _vaccineService = VaccineService();
  Map<String, List<Vaccination>> _allVaccinations = {};
  bool _isLoading = true;
  String _filterStatus = 'all'; // all, overdue, due_soon, up_to_date

  @override
  void initState() {
    super.initState();
    _loadAllVaccinations();
  }

  Future<void> _loadAllVaccinations() async {
    setState(() => _isLoading = true);
    try {
      final vaccinations = await _vaccineService.getAllUserPetVaccinations();
      if (mounted) {
        setState(() {
          _allVaccinations = vaccinations;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading vaccinations: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<MapEntry<String, List<Vaccination>>> _getFilteredVaccinations() {
    final entries = _allVaccinations.entries.toList();
    
    if (_filterStatus == 'all') {
      return entries;
    }

    return entries.map((entry) {
      final filtered = entry.value.where((v) {
        if (_filterStatus == 'overdue') return v.status == 'overdue';
        if (_filterStatus == 'due_soon') return v.status == 'due_soon' || v.status == 'due';
        if (_filterStatus == 'up_to_date') return v.status == 'up_to_date' || v.status == 'upcoming';
        return true;
      }).toList();
      return MapEntry(entry.key, filtered);
    }).where((entry) => entry.value.isNotEmpty).toList();
  }

  int _getTotalCount(String status) {
    int count = 0;
    for (var entry in _allVaccinations.entries) {
      for (var v in entry.value) {
        if (status == 'all') {
          count++;
        } else if (status == 'overdue' && v.status == 'overdue') {
          count++;
        } else if (status == 'due_soon' && (v.status == 'due_soon' || v.status == 'due')) {
          count++;
        } else if (status == 'up_to_date' && (v.status == 'up_to_date' || v.status == 'upcoming')) {
          count++;
        }
      }
    }
    return count;
  }

  Color _getStatusColor(String status) {
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

  String _getStatusLabel(String status) {
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

  @override
  Widget build(BuildContext context) {
    final filteredVaccinations = _getFilteredVaccinations();
    final totalAll = _getTotalCount('all');
    final totalOverdue = _getTotalCount('overdue');
    final totalDueSoon = _getTotalCount('due_soon');
    final totalUpToDate = _getTotalCount('up_to_date');

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Vaccine Records'),
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all', totalAll),
                  const SizedBox(width: 8),
                  _buildFilterChip('Overdue', 'overdue', totalOverdue),
                  const SizedBox(width: 8),
                  _buildFilterChip('Due Soon', 'due_soon', totalDueSoon),
                  const SizedBox(width: 8),
                  _buildFilterChip('Up to Date', 'up_to_date', totalUpToDate),
                ],
              ),
            ),
          ),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredVaccinations.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadAllVaccinations,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredVaccinations.length,
                          itemBuilder: (context, index) {
                            final entry = filteredVaccinations[index];
                            final petName = entry.key;
                            final vaccinations = entry.value;
                            
                            return _buildPetSection(petName, vaccinations);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _filterStatus == value;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = value;
        });
      },
      selectedColor: secondaryColor.withOpacity(0.3),
      checkmarkColor: secondaryColor,
      labelStyle: TextStyle(
        color: isSelected ? secondaryColor : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildPetSection(String petName, List<Vaccination> vaccinations) {
    // Find the pet to get petId
    final pet = widget.animals.firstWhere(
      (a) => a.name == petName,
      orElse: () => widget.animals.first,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pet header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.pets, color: secondaryColor),
                    const SizedBox(width: 8),
                    Text(
                      petName,
                      style: const TextStyle(
                        fontSize: 18,
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
                        builder: (_) => VaccineDetailsPage(
                          petName: petName,
                          petId: pet.petID,
                        ),
                      ),
                    );
                  },
                  child: const Text('View Details'),
                ),
              ],
            ),
          ),
          // Vaccine list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: vaccinations.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final vaccine = vaccinations[index];
              return _buildVaccineItem(vaccine);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVaccineItem(Vaccination vaccine) {
    final statusColor = _getStatusColor(vaccine.status);
    final statusLabel = _getStatusLabel(vaccine.status);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.vaccines, color: statusColor, size: 24),
      ),
      title: Text(
        vaccine.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text('Next due: ${DateFormat('MMM dd, yyyy').format(vaccine.nextDueDate)}'),
          Text(
            vaccine.daysUntilDue < 0
                ? '${vaccine.daysUntilDue.abs()} days overdue'
                : vaccine.daysUntilDue == 0
                    ? 'Due today'
                    : 'Due in ${vaccine.daysUntilDue} days',
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          statusLabel,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.vaccines_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              _filterStatus == 'all'
                  ? 'No Vaccine Records'
                  : 'No Vaccines Match Filter',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _filterStatus == 'all'
                  ? 'Add vaccine records to start tracking'
                  : 'Try a different filter to see other vaccines',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
