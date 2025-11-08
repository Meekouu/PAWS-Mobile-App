import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/vaccine_model.dart';
import '../services/vaccine_service.dart';
import '../themes/themes.dart';
import 'add_vaccination_page.dart';

class VaccineDetailsPage extends StatefulWidget {
  final String petName;
  final String petId;

  const VaccineDetailsPage({
    super.key,
    required this.petName,
    required this.petId,
  });

  @override
  State<VaccineDetailsPage> createState() => _VaccineDetailsPageState();
}

class _VaccineDetailsPageState extends State<VaccineDetailsPage> {
  final VaccineService _vaccineService = VaccineService();
  List<Vaccination> _vaccinations = [];
  bool _isLoading = true;
  String _filterStatus = 'all'; // 'all', 'overdue', 'due_soon', 'up_to_date'

  @override
  void initState() {
    super.initState();
    _loadVaccinations();
  }

  Future<void> _loadVaccinations() async {
    setState(() => _isLoading = true);
    try {
      final allVaccinations = await _vaccineService.getAllUserPetVaccinations();
      final petVaccinations = allVaccinations[widget.petName] ?? [];
      
      if (mounted) {
        setState(() {
          _vaccinations = petVaccinations;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading vaccinations: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Vaccination> get _filteredVaccinations {
    if (_filterStatus == 'all') return _vaccinations;
    
    return _vaccinations.where((vaccine) {
      final status = vaccine.status;
      switch (_filterStatus) {
        case 'overdue':
          return status == 'overdue';
        case 'due_soon':
          return status == 'due' || status == 'due_soon';
        case 'up_to_date':
          return status == 'up_to_date' || status == 'upcoming';
        default:
          return true;
      }
    }).toList();
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

  IconData _getStatusIcon(String status) {
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

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _filterStatus == value;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey[700]),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = value;
        });
      },
      selectedColor: secondaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.grey[100],
    );
  }

  Widget _buildVaccineCard(Vaccination vaccine) {
    final status = vaccine.status;
    final statusColor = _getStatusColor(status);
    final statusLabel = _getStatusLabel(status);
    final statusIcon = _getStatusIcon(status);
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
            // Vaccine Name and Status Badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    vaccine.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        size: 16,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Vaccine Details
            _buildDetailRow(
              Icons.event,
              'Last Given',
              DateFormat('MMM dd, yyyy').format(vaccine.date),
              Colors.blue,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.event_available,
              'Next Due',
              DateFormat('MMM dd, yyyy').format(vaccine.nextDueDate),
              statusColor,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.timer,
              'Days Until Due',
              daysUntilDue < 0 
                  ? '${daysUntilDue.abs()} days overdue' 
                  : daysUntilDue == 0 
                      ? 'Due today' 
                      : '$daysUntilDue days',
              statusColor,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.medical_services,
              'Veterinarian',
              vaccine.veterinarian,
              Colors.grey,
            ),
            if (vaccine.batchNumber != null && vaccine.batchNumber!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildDetailRow(
                Icons.qr_code,
                'Batch Number',
                vaccine.batchNumber!,
                Colors.grey,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final isAll = _filterStatus == 'all';
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
              isAll ? 'No Vaccines Found' : 'No Vaccines Match Filter',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isAll
                  ? 'No vaccination records for ${widget.petName}'
                  : 'Try a different filter to see other vaccines',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            if (isAll) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  final added = await showDialog<bool>(
                    context: context,
                    builder: (_) => AddVaccinationDialog(
                      petName: widget.petName,
                      petId: widget.petId,
                    ),
                  );
                  if (added == true) {
                    _loadVaccinations();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Vaccine Record'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vaccine Records',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.petName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter Chips
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.grey[50],
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', 'all', Icons.list),
                        const SizedBox(width: 8),
                        _buildFilterChip('Overdue', 'overdue', Icons.warning_amber_rounded),
                        const SizedBox(width: 8),
                        _buildFilterChip('Due Soon', 'due_soon', Icons.schedule),
                        const SizedBox(width: 8),
                        _buildFilterChip('Up to Date', 'up_to_date', Icons.check_circle),
                      ],
                    ),
                  ),
                ),

                // Vaccine List
                Expanded(
                  child: _filteredVaccinations.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadVaccinations,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _filteredVaccinations.length,
                            itemBuilder: (context, index) {
                              return _buildVaccineCard(_filteredVaccinations[index]);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
