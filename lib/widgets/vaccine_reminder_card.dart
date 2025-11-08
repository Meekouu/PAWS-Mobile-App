import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/vaccine_model.dart';
import '../services/vaccine_service.dart';
import '../pages/vaccine_details_page.dart';
import '../pages/add_vaccination_page.dart';
import '../themes/themes.dart';

class VaccineReminderCard extends StatefulWidget {
  final String petName;
  final String petId;

  const VaccineReminderCard({
    super.key,
    required this.petName,
    required this.petId,
  });

  @override
  State<VaccineReminderCard> createState() => _VaccineReminderCardState();
}

class _VaccineReminderCardState extends State<VaccineReminderCard> with AutomaticKeepAliveClientMixin {
  final VaccineService _vaccineService = VaccineService();
  Map<String, dynamic>? _vaccineSummary;
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadVaccineSummary();
  }

  Future<void> _loadVaccineSummary() async {
    try {
      final summary = await _vaccineService.getVaccineSummaryForPetId(widget.petId, widget.petName);
      if (mounted) {
        setState(() {
          _vaccineSummary = summary;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading vaccine summary: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Color _getPriorityColor(int overdue, int dueSoon) {
    if (overdue > 0) return Colors.red;
    if (dueSoon > 0) return Colors.orange;
    return Colors.green;
  }

  IconData _getStatusIcon(int overdue, int dueSoon) {
    if (overdue > 0) return Icons.warning_amber_rounded;
    if (dueSoon > 0) return Icons.schedule;
    return Icons.check_circle;
  }

  String _getStatusText(int total, int overdue, int dueSoon, int upToDate) {
    if (total == 0) return 'No vaccines recorded';
    if (overdue > 0) return '$overdue overdue';
    if (dueSoon > 0) return '$dueSoon due soon';
    return 'All up to date';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    if (_isLoading) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_vaccineSummary == null) {
      return const SizedBox.shrink();
    }

    final total = _vaccineSummary!['total'] as int;
    final upToDate = _vaccineSummary!['upToDate'] as int;
    final dueSoon = _vaccineSummary!['dueSoon'] as int;
    final overdue = _vaccineSummary!['overdue'] as int;
    final nextDue = _vaccineSummary!['nextDue'] as Vaccination?;

    // Show empty-state card if no vaccines
    if (total == 0) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        elevation: 2,
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
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.vaccines, color: Colors.grey, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.petName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('No vaccine records yet. Add the first record to start receiving reminders.',
                          style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final added = await showDialog<bool>(
                      context: context,
                      builder: (_) => AddVaccinationDialog(
                        petName: widget.petName,
                        petId: widget.petId,
                      ),
                    );
                    if (added == true) {
                      _loadVaccineSummary();
                    }
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Vaccine Record'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final statusColor = _getPriorityColor(overdue, dueSoon);
    final statusIcon = _getStatusIcon(overdue, dueSoon);
    final statusText = _getStatusText(total, overdue, dueSoon, upToDate);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VaccineDetailsPage(
                petName: widget.petName,
                petId: widget.petId,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.vaccines,
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vaccine Reminders',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.petName,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Status Summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: statusColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      statusIcon,
                      color: statusColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                    Text(
                      '$total total',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Next Due Vaccine (if exists)
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
                      Icon(
                        Icons.event,
                        color: Colors.blue[700],
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Next: ${nextDue.name}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Due: ${DateFormat('MMM dd, yyyy').format(nextDue.nextDueDate)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: nextDue.daysUntilDue < 7
                              ? Colors.orange
                              : Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${nextDue.daysUntilDue}d',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // View All Button
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VaccineDetailsPage(
                          petName: widget.petName,
                          petId: widget.petId,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.list_alt, size: 18),
                  label: const Text('View All Vaccines'),
                  style: TextButton.styleFrom(
                    foregroundColor: secondaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
